# Kotlin Developer handoff contract

<!-- kotlin-suite:DEV-HANDOFF-CONTRACT -->

Use this fallback only when an inter-agent lifecycle requires a transition. A repository-local
`KOTLIN-HANDOFF/1` contract may add stricter requirements and takes precedence. Direct or
repository-classified trivial work with no receiving lifecycle role ends with the normal
implementation and verification report, not a manufactured Reviewer handoff. When repository
policy requires a root self-review, the root loads `kotlin-reviewer` next.

## Developer routes

| From | To | Status | Meaning |
| --- | --- | --- | --- |
| `KOTLIN_DEVELOPER` | `KOTLIN_REVIEWER` | `READY` | Implementation and required evidence are ready for independent review. |
| `KOTLIN_DEVELOPER` | `KOTLIN_ARCHITECT` | `CHANGES_REQUIRED` | A binding design contradiction requires architecture revision. |
| `KOTLIN_DEVELOPER` | `ROOT` | `BLOCKED` | A user decision, authority, approval, or external state is required. |

Do not use `needs_input`. Report exact changed files, validation commands and outcomes, deviations,
and residual risks under `CURRENT-STATE`.

## KOTLIN-HANDOFF/1

Emit exactly one current Markdown block and no cumulative history:

```text
=== KOTLIN-HANDOFF/1 ===

FROM: KOTLIN_DEVELOPER
TO: KOTLIN_REVIEWER | KOTLIN_ARCHITECT | ROOT
STATUS: READY | CHANGES_REQUIRED | BLOCKED
REPO: <shared worktree, branch and revision, commit, or patch>

OBJECTIVE:
<canonical outcome of the complete task>

ACCEPTANCE:
- <observable condition required for completion>

CURRENT-STATE:
- <implementation, changed owners/files, deviations, evidence outcomes, and blocker state>

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
