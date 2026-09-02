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
| Product behavior, supported app versions, repository graph, concrete owners, current dependency pins, local naming/layout, local validation commands, and stricter project constraints | The affected project's `AGENTS.md` and routed sidecars. |
| Current implementation facts and executable behavior | The live manifests/build files, compiled APIs, source, tests, and executable guardrails. |
| Agent identity, sandbox, and MCP capability | The thin TOML profile in `MobileDevCycleAgents`. |
| Complexity class, model/reasoning selection, role order, liveness, local handoff schema, and correction routing | The affected project's lifecycle guidance. |

Repository guidance may preserve or strengthen a project-specific invariant, but it should not copy a
complete reusable rule from a skill. When a local document restates generic doctrine and the two
drift, preserve the local product invariant, apply the skill as the reusable authority, and update
or remove the duplicate project wording.

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

## Maintenance rules

- Put a reusable rule in the applicable skill or focused reference, not in a project sidecar or TOML
  profile.
- Put a product/repository decision in the project that owns it, and describe only the delta from the
  reusable skill.
- Prefer one full definition plus a short pointer elsewhere. Do not maintain parallel long-form
  formulations of the same rule.
- Keep role skills self-contained enough to run independently; do not add an always-on overlay skill
  solely to deduplicate independently loaded Swift/Kotlin or Architect/Developer/Reviewer roles.
- Preserve generic fallback handoff references for repositories that do not define a complete local
  lifecycle contract.
- After changing a skill, validate its internal links, examples/scripts when affected, and the project
  sidecars that intentionally declare stricter local deltas.
