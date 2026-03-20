#!/usr/bin/env python3
"""
Financial Scenario Calculator — generates markdown comparison tables from
income/expense definitions and scenario overrides.

Usage:
    python scenario_calc.py config.toml              # from TOML config
    python scenario_calc.py --interactive             # guided prompts
    python scenario_calc.py --json '{"income":...}'   # inline JSON

Output: markdown table printed to stdout (redirect to .md file as needed).
"""

import argparse
import json
import sys
from pathlib import Path

try:
    import tomllib  # Python 3.11+
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        tomllib = None


def load_config(path: str) -> dict:
    """Load config from TOML or JSON file."""
    p = Path(path)
    text = p.read_text(encoding="utf-8")
    if p.suffix in (".toml", ".tml"):
        if tomllib is None:
            print("ERROR: tomllib not available. Use JSON or install tomli.", file=sys.stderr)
            sys.exit(1)
        return tomllib.loads(text)
    elif p.suffix == ".json":
        return json.loads(text)
    else:
        # Try JSON first, then TOML
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            if tomllib:
                return tomllib.loads(text)
            raise


def calc_scenario(base_income: dict, base_expenses: dict, overrides: dict) -> dict:
    """Calculate a single scenario by applying overrides to base values."""
    income = {**base_income}
    expenses = {**base_expenses}

    for key, val in overrides.items():
        if key.startswith("income."):
            income[key.removeprefix("income.")] = val
        elif key.startswith("expense."):
            expenses[key.removeprefix("expense.")] = val
        elif key.startswith("-income."):
            income.pop(key.removeprefix("-income."), None)
        elif key.startswith("-expense."):
            expenses.pop(key.removeprefix("-expense."), None)

    total_in = sum(income.values())
    total_out = sum(expenses.values())
    net = total_in - total_out

    return {
        "income": income,
        "expenses": expenses,
        "total_income": total_in,
        "total_expenses": total_out,
        "net": net,
    }


def format_currency(val: float) -> str:
    """Format as currency with sign."""
    if val >= 0:
        return f"${val:,.0f}"
    return f"-${abs(val):,.0f}"


def format_net(val: float) -> str:
    """Format net with +/- prefix."""
    if val >= 0:
        return f"+${val:,.0f}"
    return f"-${abs(val):,.0f}"


def generate_comparison_table(config: dict) -> str:
    """Generate a markdown comparison table from config."""
    base_income = config.get("income", {})
    base_expenses = config.get("expenses", {})
    scenarios_def = config.get("scenarios", {})

    if not scenarios_def:
        print("ERROR: No scenarios defined.", file=sys.stderr)
        sys.exit(1)

    # Calculate all scenarios
    scenarios = {}
    for name, overrides in scenarios_def.items():
        label = overrides.pop("_label", name.replace("_", " ").title())
        scenarios[label] = calc_scenario(base_income, base_expenses, overrides)

    # Build comparison table
    lines = []
    scenario_names = list(scenarios.keys())
    header = "| Category | " + " | ".join(scenario_names) + " |"
    separator = "|----------|" + "|".join(["----------"] * len(scenario_names)) + "|"
    lines.append(header)
    lines.append(separator)

    # Income rows
    all_income_keys = set()
    for s in scenarios.values():
        all_income_keys.update(s["income"].keys())

    for key in sorted(all_income_keys):
        row = f"| {key} |"
        for name in scenario_names:
            val = scenarios[name]["income"].get(key, 0)
            row += f" {format_currency(val)} |"
        lines.append(row)

    # Income total
    row = "| **Total Income** |"
    for name in scenario_names:
        row += f" **{format_currency(scenarios[name]['total_income'])}** |"
    lines.append(row)

    # Spacer
    row = "| | " + " | ".join([""] * len(scenario_names)) + " |"
    lines.append(row)

    # Expense rows
    all_expense_keys = set()
    for s in scenarios.values():
        all_expense_keys.update(s["expenses"].keys())

    for key in sorted(all_expense_keys):
        row = f"| {key} |"
        for name in scenario_names:
            val = scenarios[name]["expenses"].get(key, 0)
            row += f" {format_currency(val)} |"
        lines.append(row)

    # Expense total
    row = "| **Total Expenses** |"
    for name in scenario_names:
        row += f" **{format_currency(scenarios[name]['total_expenses'])}** |"
    lines.append(row)

    # Net
    row = "| **Monthly Net** |"
    for name in scenario_names:
        row += f" **{format_net(scenarios[name]['net'])}** |"
    lines.append(row)

    # Title
    title = config.get("title", "Financial Scenario Comparison")
    output = f"# {title}\n\n"
    output += "\n".join(lines) + "\n"

    # Notes
    if "notes" in config:
        output += f"\n---\n**Notes**: {config['notes']}\n"

    return output


def interactive_mode() -> dict:
    """Guided prompts for building a scenario config."""
    config = {"income": {}, "expenses": {}, "scenarios": {}}

    print("=== Financial Scenario Calculator ===\n")
    config["title"] = input("Title (default: Financial Scenarios): ").strip() or "Financial Scenarios"

    print("\n--- Base Income Sources ---")
    print("Enter income sources (name=amount). Empty line to finish.")
    while True:
        entry = input("  > ").strip()
        if not entry:
            break
        if "=" in entry:
            name, val = entry.split("=", 1)
            config["income"][name.strip()] = float(val.strip())

    print("\n--- Base Monthly Expenses ---")
    print("Enter expenses (name=amount). Empty line to finish.")
    while True:
        entry = input("  > ").strip()
        if not entry:
            break
        if "=" in entry:
            name, val = entry.split("=", 1)
            config["expenses"][name.strip()] = float(val.strip())

    print("\n--- Scenarios ---")
    print("Each scenario overrides base values. Format: income.NAME=VAL or expense.NAME=VAL")
    print("Prefix with - to remove (e.g., -income.ActiveDutyPay)")
    print("Empty scenario name to finish.\n")
    while True:
        sname = input("Scenario name: ").strip()
        if not sname:
            break
        config["scenarios"][sname] = {}
        config["scenarios"][sname]["_label"] = sname
        print(f"  Overrides for '{sname}' (empty line to finish):")
        while True:
            override = input("    > ").strip()
            if not override:
                break
            if "=" in override:
                key, val = override.split("=", 1)
                config["scenarios"][sname][key.strip()] = float(val.strip())

    return config


def main():
    parser = argparse.ArgumentParser(description="Financial scenario comparison table generator")
    parser.add_argument("config", nargs="?", help="Path to TOML or JSON config file")
    parser.add_argument("--interactive", action="store_true", help="Guided interactive mode")
    parser.add_argument("--json", type=str, help="Inline JSON config string")
    parser.add_argument("--output", "-o", type=str, help="Output file path (default: stdout)")
    args = parser.parse_args()

    if args.interactive:
        config = interactive_mode()
    elif args.json:
        config = json.loads(args.json)
    elif args.config:
        config = load_config(args.config)
    else:
        parser.print_help()
        sys.exit(1)

    result = generate_comparison_table(config)

    if args.output:
        Path(args.output).write_text(result, encoding="utf-8")
        print(f"Written to {args.output}", file=sys.stderr)
    else:
        print(result)


if __name__ == "__main__":
    main()
