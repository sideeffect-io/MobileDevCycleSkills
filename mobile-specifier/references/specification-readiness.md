# Specification readiness and output

Use this reference to decide readiness, run the question loop, and emit `MOBILE-SPEC/1`.

## Repository grounding

Use read-only inspection. Treat manifests, build configuration, production source, and tests as
implementation truth; product contracts supply durable intent and technical guidance supplies local
policy. Report a prose-versus-source conflict when it changes product intent. An explicit request to
change behavior overrides current behavior within its stated scope.

Assess only applicable categories:

- platform, repository, surface, entry point, audience, objective, success, and scope;
- interaction, navigation, dismissal, cancellation, and meaningful loading/empty/error states;
- data meaning, persistence, synchronization, migration, sharing, authorization, or destruction;
- permission, privacy, background/recovery, external entry, and system-surface behavior;
- copy/assets, accessibility, localization, adaptive layout, and required parity; and
- observable acceptance conditions that distinguish completion from an incomplete result.

Mark `SPEC_NOT_READY` only when a material gap remains: multiple plausible user-visible outcomes,
unclear scope or success, missing safety/privacy/destructive/external-entry policy required by the
capability, a product-rule conflict needing intentional resolution, or an inaccessible required
copy/asset/data contract/entitlement/reference.

## Questions and product-contract delta

Explain the repository evidence behind each question. Prefer two or three mutually exclusive
choices with the recommended repository-aligned default first and the consequence of each choice.
Use free form only when choices cannot be enumerated. If the user delegates to existing behavior or
platform convention, choose the strongest repository-backed default and record it.

Reference existing product-rule IDs instead of copying their text. A product-contract delta exists
when the specification adds or changes durable observable behavior, data meaning, privacy/security,
destructive action, or cross-platform parity. For shared behavior outside the counterpart's current
scope, record the synchronization follow-up. Use `PRODUCT-CONTRACT-DELTA: NONE` for implementation
or refactoring of existing accepted rules.

## Output contract

The block must be the final response content. Brief context may precede it; nothing may follow it.

```text
=== MOBILE-SPEC/1 ===

STATUS: SPEC_READY | SPEC_NOT_READY
PLATFORMS: IOS | ANDROID | IOS_AND_ANDROID

REPOSITORIES:
- <absolute path and branch, or explicit unavailable state>

OBJECTIVE:
<canonical implementation outcome or task-contract path/revision plus its active delta>

ACCEPTANCE:
- <observable condition, or task-contract acceptance reference plus changed condition>

CONTEXT:
- <only relevant current behavior, evidence, conflicts, and source references>
- PRODUCT-CONTRACT-DELTA: NONE | <stable rule IDs and outcome>

BINDING:
- NONE | <product rule, decision, or repository constraint>

ASSUMPTIONS:
- NONE | <low-risk inferred default>

OUT-OF-SCOPE:
- NONE | <excluded behavior or deliberately unmodeled adverse path>

BLOCKERS:
- NONE | <material unresolved decision or inaccessible required input>

QUESTIONS:
- NONE | <repository-grounded question, options, recommendation, and consequences>

NEXT: REFINE_SPEC | CLASSIFY_COMPLEXITY

=== END ===
```

For `SPEC_READY`, blockers and questions are `NONE`, and `NEXT` is `CLASSIFY_COMPLEXITY`. For
`SPEC_NOT_READY`, name at least one blocker and use `REFINE_SPEC`; questions may be `NONE` only when
the sole blocker is inaccessible repository or external state. Emit exactly one current block. Do
not add a third status, readiness score, complexity class, implementation plan, or lifecycle
approval.
