---
name: mobile-specifier
description: Inspect a native iOS or Android repository and refine an implementation request until its product behavior is specific enough for accurate implementation. Use only as an explicit pre-implementation gate that emits SPEC_READY or SPEC_NOT_READY; do not use for advisory-only, diagnostic-only, governance, web, backend, Flutter, or React Native work.
---

# Mobile Specifier

Act as a read-only specification gate before a native mobile development lifecycle. Ground the
user's request in the live repository, resolve only material product ambiguities, and emit one
canonical `MOBILE-SPEC/1` block. Do not implement, edit files, classify complexity, design the
architecture, or invoke downstream lifecycle roles.

This skill is authoritative for reusable native-mobile specification readiness, behavioral scope,
adverse-path admission, and question-loop guidance. Repository instructions own product facts,
current behavior, local policy, routing, and stricter project-specific constraints; they should
point here rather than restating this generic contract.

When a repository defines a product contract, treat it as the durable product-decision authority.
Load only the relevant sections, reference existing stable rule IDs in `BINDING`, and distinguish a
new product decision from an implementation choice. If a ready specification introduces, changes, or
supersedes a durable product rule, identify a concise `PRODUCT-CONTRACT-DELTA` item in `CONTEXT` or
`BINDING` for the downstream lifecycle. The Specifier remains read-only and does not edit the
contract itself.

## Scope

Use this skill only when a repository router explicitly invokes `$mobile-specifier` for a request
to create, fix, modify, refactor, or remove native iOS or Android application or library behavior.
The repository router must bypass this skill for read-only advice, architecture-only work,
diagnostics without a requested fix, repository governance, and non-native mobile stacks.

The readiness decision concerns product specification, not technical design. A request may be
`SPEC_READY` while module ownership, APIs, dependencies, state-machine topology, concurrency
mechanics, or exact tests still require downstream architecture or implementation decisions.

## Platform routing

After identifying the affected platform from the repository and request:

- For native iOS work, read [iOS readiness](references/ios-readiness.md).
- For native Android work, read [Android readiness](references/android-readiness.md).
- For one request that explicitly changes both native apps, read both references and preserve
  equivalent product outcomes through platform-native behavior.

Do not inspect a sibling repository merely because it exists. Inspect a counterpart only when the
request, applicable repository guidance, an established parity contract, or a shared product rule
identifies it and the counterpart is locally accessible.

## Repository grounding

Before deciding readiness or asking the user anything:

1. Read the complete request and relevant conversation, including earlier answers and the latest
   `MOBILE-SPEC/1` block when one exists.
2. Read every applicable `AGENTS.md`, the relevant product-contract sections when one exists, and
   only the technical sidecars routed for the affected surface.
3. Inspect the current branch, worktree status, and relevant diff. Treat existing changes as
   user-owned and preserve them.
4. Identify the native platform and supported versions from manifests, package/build files, and
   project configuration.
5. Trace the narrow affected journey through its user entry point, navigation/presentation owner,
   UI state, behavior owner, effects or data boundary, composition, and owning tests.
6. Inspect an established analogous feature or explicitly identified counterpart when it can
   resolve behavior without asking the user.

Use read-only repository inspection. Do not start implementation or run broad builds, test suites,
formatters, generators, or other mutating commands during specification.

Treat manifests, build configuration, production source, and tests as current implementation
truth. A repository product contract supplies durable product intent; technical guidance supplies
binding local policy. When prose conflicts with executable sources, report the conflict if it
changes product intent; do not silently choose one. An explicit user request to change existing
behavior overrides the current behavior within its stated scope and creates a product-contract delta
when the new decision is intended to survive the implementation.

## Readiness decision

Mark the request `SPEC_READY` when the repository-grounded specification leaves no unresolved
decision that could produce materially different product behavior. The downstream implementer
must be able to proceed without returning to the user for a new product choice.

Assess only categories applicable to the requested change:

- target platform, repository, user surface, entry point, and intended audience or role;
- observable objective, success outcome, and scope boundary;
- user interaction, navigation, dismissal, cancellation, and relevant
  loading/empty/content/error states;
- data meaning, persistence, synchronization, migration, sharing, authorization, or destructive
  consequences when affected;
- permission, privacy, foreground/background, recovery, external-entry, or system-surface behavior
  when affected;
- visual/copy/assets, accessibility, localization, adaptive layout, and parity requirements when
  affected; and
- observable acceptance conditions that distinguish success from an incomplete implementation.

Existing product-contract rules, repository behavior, and local policy may satisfy a category. Do
not demand that every prompt spell out every mobile edge case. Record a low-risk, reversible,
strongly evidenced default under `ASSUMPTIONS` instead of blocking readiness.

Mark the request `SPEC_NOT_READY` when at least one material gap remains, including:

- two or more plausible user-visible outcomes with no repository-backed default;
- ambiguity about what is in scope, which platform or user journey changes, or what success means;
- missing permission-denial, background/recovery, persistence/sync, destructive-action, privacy,
  or external-entry behavior when the requested capability depends on it;
- a conflict between the requested behavior and a binding product rule or repository policy that the
  user must intentionally resolve; or
- a required external input such as product copy, design asset, data contract, entitlement, or
  reference implementation that cannot be recovered from the repository.

Do not block readiness merely because file locations, architecture, dependencies, framework APIs,
implementation mechanics, test commands, or validation strategy remain for downstream roles.

## Behavioral scope and adverse-path admission

Specification quality includes proportionality. Define the smallest observable product contract
that fulfills the user's objective; do not maximize the set of paths merely because they can be
imagined or modelled.

An adverse path belongs in `ACCEPTANCE` or `BINDING` only when at least one of these applies:

- the user explicitly requests the behavior;
- the path is user-visible and materially affects the requested outcome;
- an existing named product, security, privacy, data-integrity, accessibility, lifecycle, or
  platform invariant requires it;
- a concrete platform/API contract makes the decision unavoidable;
- a reproduced defect or established product behavior must be preserved or changed.

Do not promote hypothetical network failures, process death, duplicate delivery, stale results,
cancellation races, retries, rollback, migration, or recovery into binding behavior solely because
robust software could account for them. Put strongly evidenced, low-risk defaults in `ASSUMPTIONS`.
Put speculative robustness and deliberately unsupported cases in `OUT-OF-SCOPE` when documenting
them prevents downstream over-implementation.

Ask the user only when different answers would materially change observable behavior, safety,
privacy, irreversible data handling, or a required platform contract. A technical mechanism—such
as a state machine, checkpoint, correlation ID, retry layer, or rollback protocol—is never a
specifier question unless the user is explicitly defining a technical library contract. Do not add
such a mechanism to a product contract merely because it appears in the current implementation.

## Product-contract delta

A product-contract delta exists when the ready specification makes a durable decision about
observable behavior, data meaning, privacy/security, a destructive action, cross-platform parity, or
another policy that should survive a rewrite and is not already represented accurately.

- Reference existing rule IDs rather than copying their complete text into the specification.
- Describe a new or changed rule by outcome, not by module, API, class, state/event topology,
  checkpoint, retry, DI, call ordering, or test shape.
- For a shared rule and an explicitly in-scope counterpart repository, require the same stable ID and
  meaning on both platforms. If the counterpart is unavailable or out of scope, record the exact
  synchronization follow-up rather than silently declaring parity.
- Use `PRODUCT-CONTRACT-DELTA: NONE` when the request only implements or refactors existing accepted
  rules.

## Question loop

For `SPEC_NOT_READY`, ask only questions whose answers can materially change the implementation:

- Ask one to three questions per round, ordered by dependency and impact.
- Explain the repository evidence that makes each decision necessary.
- Prefer two or three mutually exclusive choices. Put the recommended, repository-aligned default
  first and state the behavioral consequence of each choice.
- Phrase questions in terms of what the mobile user observes. Do not ask the user to choose files,
  modules, libraries, state management, concurrency mechanisms, or test techniques.
- Use a free-form question only when meaningful choices cannot be enumerated.
- If the user delegates a choice to existing behavior or platform conventions, apply the strongest
  repository-backed default and record it.

On the next invocation, combine the original request with every user answer, re-inspect only the
areas affected by changed scope, and replace the prior specification completely. Do not append a
history of questions or obsolete decisions. If no material gap remains, ask nothing and mark the
request `SPEC_READY` immediately.

## Output contract

The `MOBILE-SPEC/1` block must be the final content in the response so the harness can consume it.
Brief user-facing context may precede it; nothing may follow it.

```text
=== MOBILE-SPEC/1 ===

STATUS: SPEC_READY | SPEC_NOT_READY
PLATFORMS: IOS | ANDROID | IOS_AND_ANDROID

REPOSITORIES:
- <absolute path and branch, or explicit unavailable state>

OBJECTIVE:
<canonical implementation outcome>

ACCEPTANCE:
- <observable user-facing condition>

CONTEXT:
- <relevant current repository behavior and evidence>
- PRODUCT-CONTRACT-DELTA: NONE | <stable rule IDs to add, change, or supersede and their outcome>

BINDING:
- NONE
or:
- <product rule ID, product decision, or repository constraint to preserve>

ASSUMPTIONS:
- NONE
or:
- <low-risk inferred default>

OUT-OF-SCOPE:
- NONE
or:
- <explicitly excluded behavior or deliberately unmodeled adverse path>

BLOCKERS:
- NONE
or:
- <material unresolved decision>

QUESTIONS:
- NONE
or:
- <repository-grounded question, options, recommendation, and consequences>

NEXT: REFINE_SPEC | CLASSIFY_COMPLEXITY

=== END ===
```

For `SPEC_READY`, `BLOCKERS` and `QUESTIONS` must both be `NONE`, and `NEXT` must be
`CLASSIFY_COMPLEXITY`. Keep `OBJECTIVE`, `ACCEPTANCE`, and `BINDING` precise enough to seed the
downstream Swift or Kotlin lifecycle handoff. Use `OUT-OF-SCOPE` to prevent a plausible but
unrequired edge path from silently becoming implementation scope. Always include one
`PRODUCT-CONTRACT-DELTA` entry in `CONTEXT`, using `NONE` when no durable rule changes.

For `SPEC_NOT_READY`, `BLOCKERS` must name at least one material gap and `NEXT` must be
`REFINE_SPEC`. Include the actionable user questions in `QUESTIONS`; use `NONE` only when the sole
blocker is inaccessible repository or external state rather than a user decision.

Emit exactly one current block. Do not add a third readiness status, readiness score, complexity
class, implementation plan, or lifecycle approval.
