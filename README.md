# Mobile Development Cycle Skills

This repository contains the complete reusable skills for a native mobile development cycle. Each
role skill is independently loadable and owns the engineering doctrine needed for that role; project
repositories add only product facts, repository topology, local policy, orchestration, and stricter
project-specific deltas.

## Guidance authority

Use the following ownership model:

| Guidance | Source of truth |
| --- | --- |
| Reusable Swift/Kotlin architecture, functional design, mechanism admission, state-machine semantics, concurrency, UI, testing, evidence, proportionality, and review method | The applicable skill and its routed references in this repository. |
| Durable product behavior, data meaning, privacy/destructive-action policy, and cross-platform product decisions | The affected project's product contract when it defines one. |
| Supported app versions, repository graph, concrete owners, current dependency pins, local naming/layout, local validation commands, and stricter project constraints | The affected project's `AGENTS.md` and routed technical sidecars. |
| Current implementation facts and executable behavior | The live manifests/build files, compiled APIs, source, tests, and executable guardrails. |
| Agent identity, sandbox, and MCP capability | The thin TOML profile in `MobileDevCycleAgents`. |
| Complexity class, model/reasoning selection, role order, liveness, local handoff schema, and correction routing | The affected project's lifecycle guidance. |

Repository guidance may preserve or strengthen a project-specific invariant, but it should not copy a
complete reusable rule from a skill. Technical sidecars should refer to stable product-rule IDs
instead of maintaining a second long-form definition. When sources drift, preserve explicit accepted
product intent, apply the role skill as reusable engineering authority, and update the duplicate or
obsolete guidance.

## Product-contract maintenance

When a repository defines a product contract, lifecycle roles treat it as the durable product-
decision authority:

- the Specifier reads relevant rules, references existing IDs, and identifies a contract delta when
  the ready specification introduces or changes durable product behavior;
- the Architect separates the product rule from the proposed mechanism and carries the required rule
  delta into the implementation handoff;
- the Developer updates the product contract in the same focused change as the implementation and
  reports affected rule IDs or `NONE`;
- the Reviewer blocks readiness when an accepted durable product decision exists only in chat, a
  handoff, code, or tests, or when implementation mechanics are incorrectly promoted into product
  policy.

A product-contract entry records observable behavior, durable data meaning, privacy/security or
destructive-action policy, cross-platform parity, or another decision intended to survive a rewrite.
It does not normally record modules, classes, APIs, state/event topology, checkpoints, retries, DI,
call sequences, or test commands. Shared rules use stable IDs across all in-scope platform
repositories; update each copy in the same change or record an explicit synchronization follow-up
when a counterpart is unavailable.

## Skills

| Skill | Purpose |
| --- | --- |
| `mobile-specifier` | Refines a native mobile implementation request into one repository-grounded product specification before complexity classification. |
| `swift-architect` | Designs and assesses Swift/iOS/macOS architecture and admitted mechanisms. |
| `swift-developer` | Implements and validates settled Swift architecture. |
| `swift-reviewer` | Independently assesses Swift changes, evidence, necessity, and readiness. |
| `kotlin-architect` | Designs and assesses Kotlin/Android architecture and admitted mechanisms. |
| `kotlin-developer` | Implements and validates settled Kotlin/Android architecture. |
| `kotlin-reviewer` | Independently assesses Kotlin/Android changes, evidence, necessity, and readiness. |

Load one lifecycle role skill at a time. Load only the references selected by that skill's resource
routing table and only when the current task needs them. Specialist skills supplement the active
role; they do not replace it or create an additional lifecycle stage.

## Handoff loading

The role directories include generic `handoff-contract.md` references so the skills remain portable.
A project may instead define a complete local schema, transition table, field validation, size limits,
and correction routes. In that case the project contract is the sole handoff-format authority for
that lifecycle and the generic reference must not be loaded merely to merge duplicate instructions.
The role skill still remains authoritative for reusable Architect, Developer, or Reviewer behavior.

## Independently loadable reference copies

Some focused references intentionally exist under more than one role directory. In particular, the
Swift Architect and Swift Developer currently carry the same state-machine reference so either skill
can be installed and loaded independently without a cross-skill dependency or an always-on overlay.
Only the active role loads its local copy, so this maintenance duplication does not add two copies to
one role context.

Keep copies semantically synchronized—and byte-identical when they express the same contract. Split
them only when the roles genuinely need different reference content. Do not replace role-local copies
with a shared overlay whose unconditional loading would increase context for unrelated work.

## Maintenance rules

- Put a reusable rule in the applicable skill or focused reference, not in a project sidecar or TOML
  profile.
- Put a durable product decision in the project's product contract when one exists; put repository
  ownership, platform constraints, and validation details in their technical sidecars.
- Prefer one full definition plus a short pointer elsewhere. Do not maintain parallel long-form
  formulations of the same rule.
- Keep role skills self-contained enough to run independently; do not add an always-on overlay skill
  solely to deduplicate independently loaded Swift/Kotlin or Architect/Developer/Reviewer roles.
- Preserve generic fallback handoff references for repositories that do not define a complete local
  lifecycle contract.
- After changing a skill, validate its internal links, examples/scripts when affected, synchronized
  role-local reference copies, and project sidecars that intentionally declare stricter local deltas.
