"""Validate the three self-contained Swift role skill bundles."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
SKILL_NAMES = ("swift-architect", "swift-developer", "swift-reviewer")
WORD_BUDGET = 1_000
LINK_PATTERN = re.compile(r"\[[^\]\n]+\]\(([^)\n]+)\)")
HEADING_PATTERN = re.compile(r"^#{1,6}\s+(.+?)\s*$", re.MULTILINE)
LITERAL_PATH_PATTERN = re.compile(
    r"`((?:\.\./)?(?:assets|references|scripts)/[^`\s]+)`"
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--compile",
        action="store_true",
        help="Also type-check snippets and build/test the teaching fixtures.",
    )
    return parser.parse_args()


def github_anchor(heading: str) -> str:
    heading = re.sub(r"`([^`]*)`", r"\1", heading).lower()
    heading = re.sub(r"<[^>]+>", "", heading)
    heading = re.sub(r"[^\w\- ]", "", heading)
    return re.sub(r"\s+", "-", heading.strip())


def local_target(raw_target: str) -> tuple[str, str] | None:
    target = raw_target.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    else:
        target = target.split(maxsplit=1)[0]
    if re.match(r"^[a-z][a-z0-9+.-]*:", target) or target.startswith("//"):
        return None
    path, separator, anchor = target.partition("#")
    return unquote(path), unquote(anchor) if separator else ""


def validate_frontmatter(skill_dir: Path, errors: list[str]) -> None:
    skill_file = skill_dir / "SKILL.md"
    text = skill_file.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if match is None:
        errors.append(f"{skill_file}: missing YAML frontmatter")
        return

    frontmatter = match.group(1)
    name_match = re.search(r"^name:\s*([^\n]+)$", frontmatter, re.MULTILINE)
    description_match = re.search(
        r"^description:\s*([^\n]+)$", frontmatter, re.MULTILINE
    )
    name = name_match.group(1).strip().strip('"') if name_match else ""
    description = (
        description_match.group(1).strip().strip('"') if description_match else ""
    )
    if name != skill_dir.name:
        errors.append(f"{skill_file}: frontmatter name is {name!r}")
    if not description or len(description) > 300:
        errors.append(
            f"{skill_file}: description must be discriminating and at most 300 characters"
        )

    expected_actions = {
        "swift-architect": ("design", "audit"),
        "swift-developer": ("implement", "refactor", "debug", "test"),
        "swift-reviewer": ("review",),
    }[skill_dir.name]
    first_words = description[:100].lower()
    if not any(action in first_words for action in expected_actions):
        errors.append(f"{skill_file}: description does not front-load role triggers")
    expected_boundary = {
        "swift-architect": "unsettled",
        "swift-developer": "settled",
        "swift-reviewer": "do not edit",
    }[skill_dir.name]
    if expected_boundary not in description.lower():
        errors.append(f"{skill_file}: description lacks its role boundary")

    word_count = len(text.split())
    if word_count > WORD_BUDGET:
        errors.append(
            f"{skill_file}: {word_count} words exceeds the {WORD_BUDGET}-word entry budget"
        )

    metadata = (skill_dir / "agents/openai.yaml").read_text(encoding="utf-8")
    short_match = re.search(
        r'^\s*short_description:\s*"([^"]+)"\s*$', metadata, re.MULTILINE
    )
    prompt_match = re.search(
        r'^\s*default_prompt:\s*"([^"]+)"\s*$', metadata, re.MULTILINE
    )
    if short_match is None or not 25 <= len(short_match.group(1)) <= 64:
        errors.append(
            f"{skill_dir}/agents/openai.yaml: short_description must be 25-64 chars"
        )
    if prompt_match is None or f"${skill_dir.name}" not in prompt_match.group(1):
        errors.append(
            f"{skill_dir}/agents/openai.yaml: default_prompt must name the skill"
        )
    if "allow_implicit_invocation: true" not in metadata:
        errors.append(
            f"{skill_dir}/agents/openai.yaml: implicit discovery must remain enabled"
        )


def validate_markdown(markdown: Path, errors: list[str]) -> None:
    text = markdown.read_text(encoding="utf-8")
    if text.count("```") % 2:
        errors.append(f"{markdown}: unbalanced fenced code block")

    for raw_target in LINK_PATTERN.findall(text):
        parsed = local_target(raw_target)
        if parsed is None:
            continue
        raw_path, anchor = parsed
        target = markdown if not raw_path else (markdown.parent / raw_path).resolve()
        if not target.exists():
            errors.append(f"{markdown}: missing link target {raw_target}")
            continue
        if anchor and target.suffix.lower() == ".md":
            target_text = target.read_text(encoding="utf-8")
            target_anchors = {
                github_anchor(heading)
                for heading in HEADING_PATTERN.findall(target_text)
            }
            if anchor not in target_anchors:
                errors.append(f"{markdown}: missing anchor #{anchor} in {target}")

    lines = text.splitlines()
    try:
        contents_index = lines.index("## Contents")
    except ValueError:
        return
    for line in lines[contents_index + 1 :]:
        if line.startswith("## "):
            break
        if line.startswith("- ") and not line.startswith("- ["):
            errors.append(f"{markdown}: Contents entry is not linked: {line}")


def validate_literal_paths(skill_dir: Path, markdown: Path, errors: list[str]) -> None:
    text = markdown.read_text(encoding="utf-8")
    for raw_path in LITERAL_PATH_PATTERN.findall(text):
        candidates = (markdown.parent / raw_path, skill_dir / raw_path)
        if not any(candidate.resolve().exists() for candidate in candidates):
            errors.append(f"{markdown}: missing literal path {raw_path}")


def validate_synced_references(errors: list[str]) -> None:
    architect = ROOT / "swift-architect/references/state-machine-features.md"
    developer = ROOT / "swift-developer/references/state-machine-features.md"
    if architect.read_bytes() != developer.read_bytes():
        errors.append(
            "Architect and Developer state-machine references are not byte-identical"
        )

    specialist_files = [
        ROOT / name / "references/specialist-skill-installation.md"
        for name in SKILL_NAMES
    ]
    if len({path.read_bytes() for path in specialist_files}) != 1:
        errors.append("Swift specialist-installation references are not byte-identical")


def validate_output_contract(errors: list[str]) -> None:
    state_dir = (
        ROOT
        / "swift-architect/assets/ArchitectureExample/Sources/ProfileFeature/StateMachine"
    )
    required = {"States.swift", "Events.swift", "Outputs.swift", "StateMachine.swift"}
    actual = {path.name for path in state_dir.glob("*.swift")}
    missing = required - actual
    legacy = {
        "ProfileStates.swift",
        "ProfileEvents.swift",
        "ProfileOutputs.swift",
        "ProfileStateMachine.swift",
    } & actual
    if missing or legacy:
        errors.append(
            f"ArchitectureExample StateMachine layout: missing={sorted(missing)}, "
            f"legacy={sorted(legacy)}"
        )
    if missing:
        return

    outputs = (state_dir / "Outputs.swift").read_text(encoding="utf-8")
    machine = (state_dir / "StateMachine.swift").read_text(encoding="utf-8")
    profile_outputs = outputs.split("public struct ProfileOutputs", 1)[-1].split(
        "enum ProfileCancellation", 1
    )[0]
    checks = {
        "ArchitectureExample lacks ProfileOutputs": (
            "public struct ProfileOutputs: Sendable" in outputs
        ),
        "ProfileOutputs lacks its semantic output member": (
            "let loadProfile: LoadProfileOutput" in profile_outputs
        ),
        "output callAsFunction does not return a side-effect function": (
            ") -> @Sendable () async -> (any Event<ProfileEvent>)?" in outputs
        ),
        "factory does not receive one ProfileOutputs value": "outputs: ProfileOutputs"
        in machine,
        "route does not use the named output": "sideEffect: outputs.loadProfile("
        in machine,
        "cancellation policy is not output-owned": (
            "enum ProfileCancellation" in outputs
            and "enum ProfileCancellation" not in machine
        ),
        "legacy dependency bag remains": (
            "ProfileStateMachineDependencies" not in (outputs + machine)
            and "dependencies:" not in machine
        ),
        "ProfileOutputs contains a raw closure capability": "@Sendable"
        not in profile_outputs,
    }
    errors.extend(message for message, passed in checks.items() if not passed)

    architect_reference = (
        ROOT / "swift-architect/references/state-machine-features.md"
    ).read_text(encoding="utf-8")
    required_reference_fragments = (
        "one owner-named `Outputs` value",
        "`callAsFunction` returns the side-effect function",
        "Output(sideEffect: outputs.cleanup())",
    )
    for fragment in required_reference_fragments:
        if fragment not in architect_reference:
            errors.append(f"state-machine reference is missing: {fragment}")

    production_swift = (
        ROOT / "swift-developer/references/production-swift.md"
    ).read_text(encoding="utf-8")
    stale_claims = (
        "Use SwiftStateMachine for significant business features",
        "Map every async result to a single explicit event",
    )
    for claim in stale_claims:
        if claim in production_swift:
            errors.append(
                f"production-swift.md retains contradictory guidance: {claim}"
            )
    if "public init(\n    signIn:" not in production_swift:
        errors.append("AuthenticationClient snippet lacks its public initializer")

    functional_design = (
        ROOT / "swift-architect/references/functional-design.md"
    ).read_text(encoding="utf-8")
    functional_fragments = (
        "@Sendable (DocumentQuery) async -> AsyncThrowingStream",
        "public init(\n    snapshots:",
        "snapshots: { await runtime.snapshots(for: $0) }",
    )
    for fragment in functional_fragments:
        if fragment not in functional_design:
            errors.append(f"DocumentClient snippet is missing: {fragment}")

    reviewer_method = (ROOT / "swift-reviewer/references/review-method.md").read_text(
        encoding="utf-8"
    )
    reviewer_fragments = (
        "factory receives one owner-named",
        "`callAsFunction` returns the side-effect function",
        "`Output(sideEffect: outputs.operation(...))`",
    )
    for fragment in reviewer_fragments:
        if fragment not in reviewer_method:
            errors.append(f"Reviewer output-contract check is missing: {fragment}")

    developer_reference_tree = "\n".join(
        path.read_text(encoding="utf-8")
        for path in (ROOT / "swift-developer/references").glob("*.md")
    )
    if "assets/ArchitectureExample" in developer_reference_tree:
        errors.append("Developer references point to the Architect-only fixture")


def validate_no_generated_state(errors: list[str]) -> None:
    forbidden_names = {".build", ".swiftpm", "__pycache__"}
    for skill_name in SKILL_NAMES:
        for path in (ROOT / skill_name).rglob("*"):
            if path.name in forbidden_names or path.suffix == ".pyc":
                errors.append(f"generated state is checked into a skill bundle: {path}")


def run(command: list[str], *, env: dict[str, str] | None = None) -> None:
    subprocess.run(command, cwd=ROOT, env=env, check=True)


def swift_block(path: Path, containing: str) -> str:
    text = path.read_text(encoding="utf-8")
    matches = [
        block
        for block in re.findall(r"```swift\n(.*?)\n```", text, re.DOTALL)
        if containing in block
    ]
    if len(matches) != 1:
        raise RuntimeError(
            f"expected one Swift block containing {containing!r} in {path}"
        )
    return matches[0]


def typecheck(label: str, source: str, environment: dict[str, str]) -> None:
    result = subprocess.run(
        [
            environment.get("SWIFTC_BIN", "swiftc"),
            "-swift-version",
            "6",
            "-strict-concurrency=complete",
            "-warnings-as-errors",
            "-parse-as-library",
            "-typecheck",
            "-",
        ],
        cwd=ROOT,
        env=environment,
        input=source,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        raise RuntimeError(f"{label} snippet failed to type-check:\n{result.stderr}")


def validate_swift_snippets(environment: dict[str, str]) -> None:
    functional = swift_block(
        ROOT / "swift-architect/references/functional-design.md",
        "struct DocumentClient",
    )
    functional_prelude = """
public struct DocumentQuery: Sendable {}
public struct DocumentSnapshot: Sendable {}
public struct DocumentWrite: Sendable {}

public final class VendorDatabase {
  public init() {}

  public func snapshots(
    for _: DocumentQuery
  ) -> AsyncThrowingStream<DocumentSnapshot, any Error> {
    AsyncThrowingStream { $0.finish() }
  }

  public func write(_: [DocumentWrite]) async throws {}
}
"""
    typecheck("DocumentClient", functional_prelude + functional, environment)

    authentication = swift_block(
        ROOT / "swift-developer/references/production-swift.md",
        "struct AuthenticationClient",
    )
    authentication_prelude = """
public enum AuthenticationProvider: Sendable { case fixture }
public struct AuthenticatedIdentity: Sendable {}
"""
    typecheck(
        "AuthenticationClient",
        authentication_prelude + authentication,
        environment,
    )

    cleanup = swift_block(
        ROOT / "swift-architect/references/state-machine-features.md",
        "struct CleanupOutput",
    )
    declarations, route = cleanup.split(
        "// StateMachine.swift, inside the matching route", 1
    )
    cleanup_prelude = """
protocol Event<SuperEvent>: Sendable { associatedtype SuperEvent }
enum AppEvent: Sendable {}
enum CleanupResult: Sendable { case success }

struct CleanupDidFinish: Event {
  typealias SuperEvent = AppEvent
  let widget: CleanupResult
  let exports: CleanupResult
  let handoffs: CleanupResult
}

struct Output {
  init(
    sideEffect _: @escaping @Sendable () async -> (any Event<AppEvent>)?
  ) {}
}
"""
    cleanup_source = (
        cleanup_prelude
        + declarations
        + "\nfunc makeOutput(outputs: AppOutputs) {\n  _ = "
        + route.strip()
        + "\n}\n"
    )
    typecheck("CleanupOutput", cleanup_source, environment)

    cancellation = swift_block(
        ROOT / "swift-reviewer/references/finding-catalog.md",
        "NSURLErrorCancelled",
    ).replace("import Foundation\n\n", "")
    cancellation_wrapper = f"""
import Foundation

enum ReviewFailure: Sendable {{ case unavailable }}
enum ReviewResult: Sendable {{
  case success(Int)
  case cancelled
  case failure(ReviewFailure)
}}

func reviewFetch(
  fetch: @escaping @Sendable () async throws -> Int
) async -> ReviewResult {{
{cancellation}
}}
"""
    typecheck("cancellation mapping", cancellation_wrapper, environment)


def main() -> int:
    args = parse_args()
    errors: list[str] = []

    for name in SKILL_NAMES:
        validate_frontmatter(ROOT / name, errors)
        for markdown in (ROOT / name).rglob("*.md"):
            validate_markdown(markdown, errors)
            validate_literal_paths(ROOT / name, markdown, errors)
    validate_markdown(ROOT / "README.md", errors)
    validate_synced_references(errors)
    validate_output_contract(errors)
    validate_no_generated_state(errors)

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1

    environment = os.environ.copy()
    environment["PYTHONDONTWRITEBYTECODE"] = "1"
    run(
        [sys.executable, "swift-architect/scripts/test_inventory_swiftpm.py"],
        env=environment,
    )
    if args.compile:
        validate_swift_snippets(environment)
        run(["bash", "swift-architect/scripts/validate_examples.sh"], env=environment)
        run(["bash", "swift-developer/scripts/validate_examples.sh"], env=environment)

    print(
        "Validated Swift skill discovery, links, synchronization, examples, and budgets."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
