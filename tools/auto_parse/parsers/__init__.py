"""Parser plugin discovery -- auto-loads all parsers from this directory."""

from __future__ import annotations

import importlib
import pkgutil
from pathlib import Path
from typing import TYPE_CHECKING

from .base import LineParser, ScanParser

if TYPE_CHECKING:
    from ..config import Config


def discover_parsers(config: Config) -> tuple[list[LineParser], list[ScanParser]]:
    """Import all parser modules and collect LineParser / ScanParser instances.

    Each module must define a ``create(config) -> LineParser | ScanParser`` function.
    """
    line_parsers: list[LineParser] = []
    scan_parsers: list[ScanParser] = []

    pkg_dir = Path(__file__).parent
    for info in pkgutil.iter_modules([str(pkg_dir)]):
        if info.name == "base":
            continue
        try:
            mod = importlib.import_module(f".{info.name}", package=__package__)
        except Exception:
            continue

        create_fn = getattr(mod, "create", None)
        if create_fn is None:
            continue

        try:
            parser = create_fn(config)
        except Exception:
            continue

        if isinstance(parser, ScanParser):
            scan_parsers.append(parser)
        elif isinstance(parser, LineParser):
            line_parsers.append(parser)

    return line_parsers, scan_parsers
