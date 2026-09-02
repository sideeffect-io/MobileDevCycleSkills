# Kotlin Reviewer handoff contract

<!-- kotlin-suite:REVIEW-HANDOFF-CONTRACT -->

Use this fallback only when an inter-agent lifecycle requires a transition. A repository-local
`KOTLIN-HANDOFF/1` contract may add stricter requirements and takes precedence. A standalone review
or repository-classified trivial root self-review ends with normal findings and a verdict, not a
manufactured Developer handoff or independent-approval claim.

## Reviewer routes

| From | To | Status | Meaning |
| --- | --- | --- | --- |
| `KOTLIN_REVIEWER` | `COMPLETE` | `APPROVED` | Acceptance, applicable gates, and required evidence pass with no unresolved required finding. |
| `KOTLIN_REVIEWER` | `KOTLIN_DEVELOPER` | `CHANGES_REQUIRED` | Implementation, test, or producible evidence findings require remediation. |
| `KOTLIN_REVIEWER` | `KOTLIN_ARCHITECT` | `CHANGES_REQUIRED` | Architecture findings require revised binding decisions before implementation. |
| `KOTLIN_REVIEWER` | `ROOT` | `BLOCKED` | A user decision, authority, approval, or external state is required. |

Do not use `needs_input`. For `TO: COMPLETE`, instruct the root to return the approved result to the
user; no new lifecycle agent is created.

## KOTLIN-HANDOFF/1

Emit exactly one current Markdown block and no cumulative history:

```text
=== KOTLIN-HANDOFF/1 ===

FROM: KOTLIN_REVIEWER
TO: COMPLETE | KOTLIN_DEVELOPER | KOTLIN_ARCHITECT | ROOT
STATUS: APPROVED | CHANGES_REQUIRED | BLOCKED
REPO: <shared worktree, branch and revision, commit, or patch>

OBJECTIVE:
<canonical outcome of the complete task>

ACCEPTANCE:
- <observable condition required for completion>

CURRENT-STATE:
- <findings, evidence outcomes, deviations, blocked checks, and residual risk>

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
