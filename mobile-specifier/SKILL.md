---
name: mobile-specifier
description: Inspect a native iOS or Android repository and refine an implementation request until its product behavior is specific enough for accurate implementation. Use only as an explicit pre-implementation gate that emits SPEC_READY or SPEC_NOT_READY; do not use for advisory-only, diagnostic-only, governance, web, backend, Flutter, or React Native work.
---

# Mobile Specifier

Act as a read-only specification gate before a native mobile development lifecycle. Ground the
request in the live repository, resolve only material product ambiguities, and emit one canonical
`MOBILE-SPEC/1` block. Do not implement, edit files, classify complexity, design architecture, or
invoke downstream roles.

Repository instructions own product facts, current behavior, local policy, routing, and stricter
constraints. Product contracts own durable product decisions. This skill owns reusable readiness,
behavioral scope, adverse-path admission, and question-loop guidance.

## Scope and routing

Use only when a repository router explicitly invokes `$mobile-specifier` for native iOS or Android
application/library implementation. Bypass it for advice, architecture-only work, diagnostics
without a requested fix, governance, backend-only work, and non-native stacks.

- For iOS, read [iOS readiness](references/ios-readiness.md).
- For Android, read [Android readiness](references/android-readiness.md).
- For a request explicitly changing both clients, read both and preserve equivalent outcomes through
  platform-native behavior.

Do not inspect a sibling repository merely because it exists. Inspect a counterpart only when the
request, repository guidance, or a shared product rule requires it and it is locally accessible.

## Workflow

1. Read the complete request, applicable `AGENTS.md`, relevant product rules, and only the routed
   technical sidecars.
2. Inspect branch, worktree, relevant diff, manifests/configuration, affected journey, behavior and
   effect owners, composition, tests, and one useful analogue when available. Preserve user work.
3. Determine whether any unresolved choice could produce materially different observable behavior,
   safety, privacy, destructive data handling, or required platform behavior.
4. Record repository-backed, reversible defaults as assumptions. Do not block on file placement,
   APIs, architecture, dependencies, state topology, concurrency mechanics, test commands, or other
   downstream engineering choices.
5. Emit the single output block defined in
   [Specification readiness and output](references/specification-readiness.md).

When a self-contained repository task contract already settles the request, cite its path and
revision, reference affected stable rule IDs, and include only the active behavioral delta,
assumptions, exclusions, and conflicts. Do not rewrite the entire task or product rules into the
specifier output.

## Readiness boundary

Return `SPEC_READY` when the downstream lifecycle can proceed without another product choice. The
architecture may still be unsettled. Return `SPEC_NOT_READY` only for a material product gap,
conflict, inaccessible required input, or external state described in the readiness reference.

Admit an adverse path only when the user requests it, it materially changes the requested outcome,
an existing product/security/privacy/data/lifecycle/platform invariant requires it, or a reproduced
defect/current behavior must be preserved or changed. Do not promote hypothetical failure,
cancellation, stale-result, retry, rollback, migration, or recovery paths into scope merely because
robust software could model them.

If durable observable behavior changes, report `PRODUCT-CONTRACT-DELTA` by outcome and stable rule
ID. Keep modules, APIs, state topology, DI, call ordering, retries, and tests out of product policy
unless the user explicitly makes a technical mechanism contractual.

Ask only questions that materially change observable behavior or a safety boundary. Ask one to
three per round, prefer repository-aligned mutually exclusive choices, and never ask the user to
select files, modules, libraries, state management, concurrency, or tests. On reinvocation, combine
all answers, reinspect only affected scope, and replace the previous specification rather than
appending history.
