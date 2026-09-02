# Swift Architect handoff contract

<!-- swift-suite:ARCH-HANDOFF-CONTRACT -->

Use this fallback only when an inter-agent lifecycle requires a transition. A repository-local
`SWIFT-HANDOFF/1` contract may add stricter requirements and takes precedence. Do not create a
handoff for a standalone architecture or advisory response unless the user explicitly requests one.

## Architect routes

| From | To | Status | Meaning |
| --- | --- | --- | --- |
| `SWIFT_ARCHITECT` | `SWIFT_DEVELOPER` | `READY` | Design is settled and implementable. |
| `SWIFT_ARCHITECT` | `ROOT` | `BLOCKED` | A user decision, authority, approval, or external state is required. |

Do not use `needs_input`. Describe the exact blocker under `CURRENT-STATE`, `ESCALATE-IF`, and
`OPEN`.

## SWIFT-HANDOFF/1

Emit exactly one current Markdown block and no cumulative history:

```text
=== SWIFT-HANDOFF/1 ===

FROM: SWIFT_ARCHITECT
TO: SWIFT_DEVELOPER | ROOT
STATUS: READY | BLOCKED
REPO: <shared worktree, branch and revision, commit, or patch>

OBJECTIVE:
<canonical outcome of the complete task>

ACCEPTANCE:
- <observable condition required for completion>

CURRENT-STATE:
- <settled design, relevant evidence, deviations, or blocker state>

BINDING:
- NONE
or:
- <decision, invariant, dependency direction, or constraint to preserve>

NEXT-OBJECTIVE:
<specific result for which the receiving role is responsible>

NEXT-INSTRUCTIONS:
1. <required action, approach, and expected result>
2. <required action, approach, and expected result>

NEXT-DISCRETION:
- NONE
or:
- <detail the receiving role may decide locally>

NEXT-VALIDATION:
- NONE
or:
- <evidence required before the next transition>

ESCALATE-IF:
- NONE
or:
- <condition requiring a route change instead of silent deviation>

OPEN:
- NONE
or:
- <unresolved issue relevant to the receiving role>

=== END ===
```

Carry `OBJECTIVE`, `ACCEPTANCE`, and active `BINDING` items forward without changing their meaning.
Do not change them silently: Root may revise `OBJECTIVE` or `ACCEPTANCE` after explicit user
direction, and Architect may supersede a `BINDING` item during an architecture correction. Record
each authorized revision and its reason in `CURRENT-STATE`.
Refresh every other section for the receiving role. `NEXT-INSTRUCTIONS` must state what to do and
how to establish the expected result.
