"""
Anthropic API wrapper with retry, circuit breaker, token budgets, and logging.
All daemon AI calls go through this module.
"""

import json
import logging
import time
from pathlib import Path
from datetime import datetime, timedelta
from dataclasses import dataclass, field

import anthropic

log = logging.getLogger("daemon.api")


@dataclass
class APICallRecord:
    """Record of a single API call for auditing."""
    timestamp: str
    model: str
    prompt_template: str
    task_id: str
    run_id: str
    input_tokens: int = 0
    output_tokens: int = 0
    status: str = "pending"
    error: str | None = None


@dataclass
class CircuitBreaker:
    """Circuit breaker: disables AI calls after N consecutive failures."""
    threshold: int = 3
    cooldown_minutes: int = 30
    consecutive_failures: int = 0
    last_failure_at: datetime | None = None
    tripped: bool = False

    def record_failure(self):
        self.consecutive_failures += 1
        self.last_failure_at = datetime.now()
        if self.consecutive_failures >= self.threshold:
            self.tripped = True
            log.warning(
                "Circuit breaker TRIPPED after %d consecutive failures. "
                "AI calls disabled for %d minutes.",
                self.consecutive_failures, self.cooldown_minutes
            )

    def record_success(self):
        self.consecutive_failures = 0
        self.tripped = False

    def is_available(self) -> bool:
        if not self.tripped:
            return True
        # Check cooldown expiry
        if self.last_failure_at:
            elapsed = datetime.now() - self.last_failure_at
            if elapsed > timedelta(minutes=self.cooldown_minutes):
                log.info("Circuit breaker cooldown expired. Resetting.")
                self.tripped = False
                self.consecutive_failures = 0
                return True
        return False


class TokenBudget:
    """Track token usage against daily and per-run budgets."""

    def __init__(self, daily_budget: int, per_run_budget: int):
        self.daily_budget = daily_budget
        self.per_run_budget = per_run_budget
        self._daily_used = 0
        self._daily_reset_date = datetime.now().date()
        self._run_usage: dict[str, int] = {}

    def _check_daily_reset(self):
        today = datetime.now().date()
        if today != self._daily_reset_date:
            self._daily_used = 0
            self._daily_reset_date = today

    def can_afford(self, run_id: str, estimated_tokens: int = 0) -> bool:
        self._check_daily_reset()
        if self._daily_used + estimated_tokens > self.daily_budget:
            log.warning("Daily token budget exhausted: %d / %d",
                        self._daily_used, self.daily_budget)
            return False
        run_used = self._run_usage.get(run_id, 0)
        if run_used + estimated_tokens > self.per_run_budget:
            log.warning("Per-run token budget exhausted for %s: %d / %d",
                        run_id, run_used, self.per_run_budget)
            return False
        return True

    def record_usage(self, run_id: str, tokens: int):
        self._check_daily_reset()
        self._daily_used += tokens
        self._run_usage[run_id] = self._run_usage.get(run_id, 0) + tokens

    @property
    def daily_remaining(self) -> int:
        self._check_daily_reset()
        return max(0, self.daily_budget - self._daily_used)


class ClaudeAPI:
    """Wrapper for Anthropic API with safety rails."""

    def __init__(self, config: dict, prompts_dir: str | Path):
        self.config = config
        self.prompts_dir = Path(prompts_dir)
        self.model_default = config.get("model_default", "claude-sonnet-4-6")
        self.model_complex = config.get("model_complex", "claude-opus-4-6")
        self.max_retries = config.get("max_retries", 3)

        # Initialize client
        self.client = anthropic.Anthropic()  # Uses ANTHROPIC_API_KEY env var

        # Safety rails
        self.circuit_breaker = CircuitBreaker(
            threshold=config.get("circuit_breaker_threshold", 3),
            cooldown_minutes=config.get("circuit_breaker_cooldown_minutes", 30),
        )
        self.budget = TokenBudget(
            daily_budget=config.get("daily_token_budget", 500000),
            per_run_budget=config.get("per_run_token_budget", 100000),
        )

        # Audit log
        self._call_log: list[APICallRecord] = []

    def load_prompt(self, template_name: str, **kwargs) -> str:
        """Load a prompt template from the prompts/ directory and format it."""
        path = self.prompts_dir / f"{template_name}.md"
        if not path.exists():
            raise FileNotFoundError(f"Prompt template not found: {path}")
        template = path.read_text(encoding="utf-8")
        if kwargs:
            template = template.format(**kwargs)
        return template

    def call(self, prompt: str, *, model: str | None = None,
             system: str | None = None, task_id: str = "",
             run_id: str = "", template_name: str = "",
             max_tokens: int = 4096) -> str:
        """
        Make a single API call with all safety checks.

        Returns the text response.
        Raises RuntimeError if circuit breaker is tripped or budget exhausted.
        """
        model = model or self.model_default

        # Safety checks
        if not self.circuit_breaker.is_available():
            raise RuntimeError(
                f"Circuit breaker is tripped. AI calls disabled for "
                f"{self.circuit_breaker.cooldown_minutes} minutes."
            )

        if not self.budget.can_afford(run_id):
            raise RuntimeError(
                f"Token budget exhausted. Daily remaining: "
                f"{self.budget.daily_remaining}"
            )

        record = APICallRecord(
            timestamp=datetime.now().isoformat(),
            model=model,
            prompt_template=template_name,
            task_id=task_id,
            run_id=run_id,
        )

        # Retry loop
        last_error = None
        for attempt in range(1, self.max_retries + 1):
            try:
                messages = [{"role": "user", "content": prompt}]
                kwargs = {
                    "model": model,
                    "max_tokens": max_tokens,
                    "messages": messages,
                }
                if system:
                    kwargs["system"] = system

                response = self.client.messages.create(**kwargs)

                # Extract text
                text = ""
                for block in response.content:
                    if block.type == "text":
                        text += block.text

                # Record usage
                input_tokens = response.usage.input_tokens
                output_tokens = response.usage.output_tokens
                total_tokens = input_tokens + output_tokens

                record.input_tokens = input_tokens
                record.output_tokens = output_tokens
                record.status = "success"
                self._call_log.append(record)

                self.budget.record_usage(run_id, total_tokens)
                self.circuit_breaker.record_success()

                log.info(
                    "API call success: model=%s template=%s tokens=%d+%d task=%s",
                    model, template_name, input_tokens, output_tokens, task_id
                )

                return text

            except anthropic.RateLimitError:
                last_error = "Rate limited"
                log.warning("Rate limited (attempt %d/%d). Waiting...",
                            attempt, self.max_retries)
                time.sleep(min(30, 5 * attempt))

            except anthropic.APIError as e:
                last_error = str(e)
                log.error("API error (attempt %d/%d): %s",
                          attempt, self.max_retries, e)
                if attempt < self.max_retries:
                    time.sleep(2 * attempt)

            except Exception as e:
                last_error = str(e)
                log.error("Unexpected error in API call: %s", e)
                break

        # All retries exhausted
        record.status = "failed"
        record.error = last_error
        self._call_log.append(record)
        self.circuit_breaker.record_failure()

        raise RuntimeError(f"API call failed after {self.max_retries} attempts: {last_error}")

    def get_call_log(self) -> list[dict]:
        """Return the call audit log as dicts."""
        return [
            {
                "timestamp": r.timestamp,
                "model": r.model,
                "prompt_template": r.prompt_template,
                "task_id": r.task_id,
                "run_id": r.run_id,
                "input_tokens": r.input_tokens,
                "output_tokens": r.output_tokens,
                "status": r.status,
                "error": r.error,
            }
            for r in self._call_log
        ]
