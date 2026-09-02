# Kotlin Engineering Signals

<!-- kotlin-suite:KOTLIN-METRICS -->

Use these defaults when the repository has no stricter rule. They are review signals, not scoring
shortcuts: cohesion, local reasoning, correctness, and a clear reason to change win over a number.
Never split an irreducible algorithm or cohesive owner mechanically.

| Concern | Target | Review signal |
| --- | --- | --- |
| Function | at most 15 logical lines | more than 30 |
| Effectful function | at most 20 logical lines | mixed policy, lifecycle, and I/O at any size |
| Independent parameters | 0-3 | review at 4; reconsider at 5 or more |
| Injected dependencies | 1-3 cohesive dependencies | broad bag or unrelated capabilities |
| Inline lambda | 5-10 logical lines | policy or lifecycle hidden inline |
| Nesting | at most 2 levels | avoid 4 or more |
| Cyclomatic complexity | at most 5 | more than 10 |
| Transformation chain | 3-5 operations | review beyond 5-7 or whenever unreadable |
| Type | 100-200 production lines | review beyond 250-300 |
| File | 150-300 production lines | review beyond 400; reconsider beyond 500-600 |
| Interface | 1-5 functions/properties | review beyond 5-7 or multiple consumer roles |
| Tuple/anonymous product | at most 3 elements | use a named value when meaning or invariants matter |
| Line width | 100-120 columns | follow the repository formatter when stricter |
| Workflow/UI state | cohesive payload | review around 10-15 unrelated properties |
| Abstraction depth | at most 2-3 indirections | flatten when tracing requires repository-wide jumps |
| Individual reducer/state-machine transition | one explicit decision | review beyond about 15 logical lines unless justified |

Separately, audit local reasoning for every non-trivial whole machine qualitatively across
state/event legality, outputs, cancellation, correlation, recovery, and child-workflow seams. Counts
only trigger that audit; they never automatically split a cohesive machine or workflow.
