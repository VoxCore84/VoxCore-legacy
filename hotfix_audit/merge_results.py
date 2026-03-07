#!/usr/bin/env python3
"""
Merge all per-table JSON results into:
  1. hotfix_audit_report.md  — summary report
  2. hotfix_cleanup.sql      — DELETE statements for redundant rows
  3. hotfix_unmapped.txt      — unmapped tables for manual review
"""

import json
import os
import glob
from datetime import datetime


RESULTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results")
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def load_results():
    results = []
    for path in sorted(glob.glob(os.path.join(RESULTS_DIR, "*.json"))):
        with open(path) as f:
            results.append(json.load(f))
    return results


def generate_report(results, unmapped_tables, warnings):
    lines = []
    lines.append("# Hotfix Redundancy Audit Report")
    lines.append(f"")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Baseline: Wago DB2 CSVs, build 12.0.1.66220")
    lines.append(f"")

    # Overall summary
    total_rows = sum(r["total_rows"] for r in results)
    total_redundant = sum(len(r["redundant"]) for r in results)
    total_override = sum(len(r["override"]) for r in results)
    total_new = sum(len(r["new"]) for r in results)
    total_neg = sum(len(r["negative_build"]) for r in results)
    total_errors = sum(len(r.get("errors", [])) for r in results)
    overall_pct = (total_redundant / total_rows * 100) if total_rows > 0 else 0

    lines.append("## Summary")
    lines.append("")
    lines.append(f"| Metric | Count |")
    lines.append(f"|---|---|")
    lines.append(f"| Tables audited | {len(results)} |")
    lines.append(f"| Total rows | {total_rows:,} |")
    lines.append(f"| **Redundant** | **{total_redundant:,}** ({overall_pct:.1f}%) |")
    lines.append(f"| Override | {total_override:,} |")
    lines.append(f"| New (not in DBC) | {total_new:,} |")
    lines.append(f"| Negative build | {total_neg:,} |")
    lines.append(f"| Tables with errors | {total_errors} |")
    lines.append(f"| Unmapped tables | {len(unmapped_tables)} |")
    lines.append("")

    # Per-table breakdown sorted by redundancy % descending
    table_stats = []
    for r in results:
        total = r["total_rows"]
        n_r = len(r["redundant"])
        n_o = len(r["override"])
        n_n = len(r["new"])
        n_nb = len(r["negative_build"])
        pct = (n_r / total * 100) if total > 0 else 0
        table_stats.append((r["table"], total, n_r, n_o, n_n, n_nb, pct))

    table_stats.sort(key=lambda x: (-x[6], -x[1]))

    lines.append("## Per-Table Breakdown")
    lines.append("")
    lines.append("| Table | Rows | Redundant | Override | New | Neg.Build | Redundancy % |")
    lines.append("|---|---|---|---|---|---|---|")
    for table, total, n_r, n_o, n_n, n_nb, pct in table_stats:
        if total == 0:
            continue
        lines.append(f"| {table} | {total:,} | {n_r:,} | {n_o:,} | {n_n:,} | {n_nb:,} | {pct:.1f}% |")

    # Errors section
    error_tables = [(r["table"], r["errors"]) for r in results if r.get("errors")]
    if error_tables:
        lines.append("")
        lines.append("## Errors")
        lines.append("")
        for table, errors in error_tables:
            for err in errors:
                lines.append(f"- **{table}**: {err}")

    # Warnings section
    if warnings:
        lines.append("")
        lines.append("## Column Coverage Warnings")
        lines.append("")
        for w in warnings:
            lines.append(f"- {w}")

    # Unmapped section
    if unmapped_tables:
        lines.append("")
        lines.append("## Unmapped Tables")
        lines.append("")
        lines.append("These hotfix tables had no matching Wago CSV and were not audited:")
        lines.append("")
        for table, rows in unmapped_tables:
            lines.append(f"- `{table}` ({rows:,} rows)")

    return "\n".join(lines)


def generate_cleanup_sql(results):
    lines = []
    lines.append("-- HOTFIX REDUNDANCY CLEANUP")
    lines.append(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("-- BEFORE RUNNING: python C:/Users/atayl/VoxCore/wago/db_snapshot.py snapshot hotfixes")
    lines.append("--")
    lines.append("SET autocommit=0;")
    lines.append("START TRANSACTION;")
    lines.append("")

    total_deletes = 0

    # Sort tables by name for predictable output
    for r in sorted(results, key=lambda x: x["table"]):
        redundant = r.get("redundant", [])
        if not redundant:
            continue

        table = r["table"]
        total = r["total_rows"]
        pct = (len(redundant) / total * 100) if total > 0 else 0
        pk_cols = r.get("pk_cols", [])

        lines.append(f"-- {table}: {len(redundant):,} redundant rows of {total:,} total ({pct:.1f}%)")

        for pk_dict in redundant:
            where_parts = []
            for col in pk_cols:
                val = pk_dict.get(col)
                if val is None:
                    where_parts.append(f"`{col}` IS NULL")
                elif isinstance(val, (int, float)):
                    where_parts.append(f"`{col}` = {val}")
                else:
                    # Escape single quotes in string values
                    escaped = str(val).replace("'", "''")
                    where_parts.append(f"`{col}` = '{escaped}'")
            where_clause = " AND ".join(where_parts)
            lines.append(f"DELETE FROM `hotfixes`.`{table}` WHERE {where_clause};")
            total_deletes += 1

        lines.append("")

    lines.append("COMMIT;")
    lines.append("")
    lines.append(f"-- Total DELETE statements: {total_deletes:,}")

    return "\n".join(lines)


def generate_unmapped(unmapped_tables):
    lines = []
    lines.append("# Unmapped Hotfix Tables")
    lines.append(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("#")
    lines.append("# These tables exist in the hotfixes database but have no")
    lines.append("# matching Wago DB2 CSV for comparison.")
    lines.append("#")
    for table, rows in sorted(unmapped_tables):
        lines.append(f"{table}\t{rows}")
    return "\n".join(lines)


def main():
    results = load_results()
    print(f"Loaded {len(results)} result files")

    # Load unmapped tables
    unmapped_path = os.path.join(OUTPUT_DIR, "hotfix_only.json")
    if os.path.exists(unmapped_path):
        with open(unmapped_path) as f:
            unmapped_names = json.load(f)
    else:
        unmapped_names = []

    # Get row counts for unmapped tables (from table_info or use 0)
    import subprocess
    mysql = "C:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
    unmapped_tables = []
    for table in unmapped_names:
        result = subprocess.run(
            [mysql, "-u", "root", "-padmin", "-h", "127.0.0.1", "hotfixes", "-N", "-e",
             f'SELECT TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA="hotfixes" AND TABLE_NAME="{table}";'],
            capture_output=True, text=True
        )
        rows = int(result.stdout.strip()) if result.stdout.strip() else 0
        unmapped_tables.append((table, rows))

    # Load warnings
    warnings_path = os.path.join(OUTPUT_DIR, "warnings.json")
    if os.path.exists(warnings_path):
        with open(warnings_path) as f:
            warnings = json.load(f)
    else:
        warnings = []

    # Generate report
    report = generate_report(results, unmapped_tables, warnings)
    report_path = os.path.join(OUTPUT_DIR, "hotfix_audit_report.md")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report)
    print(f"Report: {report_path}")

    # Generate cleanup SQL
    sql = generate_cleanup_sql(results)
    sql_path = os.path.join(OUTPUT_DIR, "hotfix_cleanup.sql")
    with open(sql_path, "w", encoding="utf-8") as f:
        f.write(sql)
    total_deletes = sql.count("\nDELETE ")
    print(f"Cleanup SQL: {sql_path} ({total_deletes:,} DELETE statements)")

    # Generate unmapped list
    unmapped_txt = generate_unmapped(unmapped_tables)
    unmapped_path = os.path.join(OUTPUT_DIR, "hotfix_unmapped.txt")
    with open(unmapped_path, "w", encoding="utf-8") as f:
        f.write(unmapped_txt)
    print(f"Unmapped: {unmapped_path}")

    # Quick summary
    total_rows = sum(r["total_rows"] for r in results)
    total_redundant = sum(len(r["redundant"]) for r in results)
    overall_pct = (total_redundant / total_rows * 100) if total_rows > 0 else 0
    print(f"\nOverall: {total_redundant:,} redundant of {total_rows:,} total ({overall_pct:.1f}%)")


if __name__ == "__main__":
    main()
