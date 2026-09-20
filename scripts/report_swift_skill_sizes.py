"""Report Swift role-skill and reference sizes for context-budget comparisons."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ROLES = ("swift-architect", "swift-developer", "swift-reviewer")


def file_record(path: Path) -> dict[str, object]:
    data = path.read_bytes()
    return {
        "path": str(path.relative_to(ROOT)),
        "bytes": len(data),
        "words": len(data.decode("utf-8").split()),
        "sha256": hashlib.sha256(data).hexdigest(),
    }


def report(roles: tuple[str, ...]) -> dict[str, object]:
    role_records: list[dict[str, object]] = []
    references: list[dict[str, object]] = []
    for role in roles:
        skill = file_record(ROOT / role / "SKILL.md")
        role_refs = [
            file_record(path)
            for path in sorted((ROOT / role / "references").glob("*.md"))
        ]
        references.extend(role_refs)
        role_records.append(
            {
                "role": role,
                "entrypoint": skill,
                "reference_count": len(role_refs),
                "reference_bytes": sum(int(item["bytes"]) for item in role_refs),
                "reference_words": sum(int(item["words"]) for item in role_refs),
            }
        )

    by_hash: dict[str, list[str]] = {}
    for item in references:
        by_hash.setdefault(str(item["sha256"]), []).append(str(item["path"]))
    duplicates = [paths for paths in by_hash.values() if len(paths) > 1]
    return {"roles": role_records, "duplicate_reference_groups": duplicates}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--role",
        action="append",
        choices=ROLES,
        dest="roles",
        help="Limit the report to one role; repeat for multiple roles.",
    )
    parser.add_argument("--json", action="store_true", help="Emit machine-readable JSON.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    roles = tuple(args.roles or ROLES)
    result = report(roles)
    if args.json:
        print(json.dumps(result, indent=2, sort_keys=True))
        return 0

    print("Swift skill context-size report")
    for item in result["roles"]:
        entrypoint = item["entrypoint"]
        print(
            f"{item['role']}: entrypoint={entrypoint['bytes']} bytes/"
            f"{entrypoint['words']} words; references={item['reference_count']} files/"
            f"{item['reference_bytes']} bytes/{item['reference_words']} words"
        )
    duplicate_groups = result["duplicate_reference_groups"]
    print(f"duplicate reference groups: {len(duplicate_groups)}")
    for paths in duplicate_groups:
        print("  " + " = ".join(paths))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
