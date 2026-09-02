# Android Layers and Gradle Modules

<!-- kotlin-suite:KOTLIN-LAYERS -->

## Contents

- Compiler-enforced boundaries
- Shared layer vocabulary and Google mapping
- Domain and Shared UI
- Frameworks and Datasources
- Features and Navigation
- Gradle modules by scale
- Application composition and dependency injection
- Visibility, dependencies, resources, and tests
- Third-party policy and validation

## Compiler-enforced boundaries

A package communicates intent; a Gradle module can enforce it. Use modules for responsibilities
whose isolation prevents a meaningful class of mistake, enables independent ownership/delivery, or
materially improves build performance. Avoid both one module exposing every implementation and a
micro-module graph whose configuration cost exceeds its boundary value.

The module graph is only one boundary. Kotlin `private`/`internal` visibility, Gradle `implementation`
versus `api`, source sets, resource ownership, DI bindings, and architecture tests determine what a
consumer can actually use. A broad umbrella module can defeat an apparently clean diagram.

## Shared layer vocabulary and Google mapping

Treat Google's architecture guidance as adaptable recommendations, not a named-framework mandate:

- [Guide to app architecture](https://developer.android.com/topic/architecture)
- [Architecture recommendations](https://developer.android.com/topic/architecture/recommendations)
- [UI layer](https://developer.android.com/topic/architecture/ui-layer)
- [Data layer](https://developer.android.com/topic/architecture/data-layer)
- [Domain layer](https://developer.android.com/topic/architecture/domain-layer)
- [Modularization](https://developer.android.com/topic/modularization)
- [Common modularization patterns](https://developer.android.com/topic/modularization/patterns)
- [Dependency injection with Hilt](https://developer.android.com/training/dependency-injection/hilt-android)
- [Hilt in multi-module apps](https://developer.android.com/training/dependency-injection/hilt-multi-module)

Use the same conceptual ownership layers as the Swift architecture skill: **Domain**, **Shared UI**,
**Frameworks**, **Datasources**, **Features**, **Navigation**, and **App composition**. These names
make cross-platform responsibilities comparable; they do not require the same package names or one
Gradle module per layer. Google's UI and data layers remain the Android application model, while
Frameworks refines its technology edge and Datasources corresponds to its data layer.

| Shared ownership layer | Google-aligned Android role | Typical Gradle shape when justified |
| --- | --- | --- |
| Domain | application models and pure policy; optional reusable use cases | `:core:model`, optional `:domain:<area>` |
| Shared UI | shared UI/common module | `:core:designsystem` or cohesive `:core:ui` |
| Frameworks | generic technology-facing common/core module | `:core:network`, `:core:database`, or `:framework:http` |
| Datasources | data layer: repositories plus hidden source adapters | `:data:<area>` or optional `:data:<area>:api` + `:data:<area>:impl` |
| Features | UI layer and feature modules | `:feature:<area>` |
| Navigation | destination and cross-feature coordination | feature/app-local or `:navigation:<area>` |
| App composition | app entry point, root graph, implementation selection | `:app` and other executable/app modules |

Use capitalized **Datasources** below for the cross-platform ownership layer. Use lowercase
**data source** for Google's network, database, DataStore, Firebase, sensor, or other single-origin
adapter inside the data layer.

## Domain and Shared UI

### Domain

Own business vocabulary, identifiers, validated values, finite failures, and pure policy without
Android UI, persistence, networking, vendor SDK, DI, or Feature dependencies. A shared
`:core:model` module can enforce this contract when several modules consume the values; packages are
enough when no independent boundary is valuable.

Google's **domain layer** specifically means optional use cases between UI and data. Add
`:domain:<area>` only for complex logic or logic reused by multiple ViewModels. Keep use cases
stateless and single-purpose; do not create forwarding use cases or a domain module solely to make a
diagram symmetrical. Data coordination and source-of-truth policy remain in the data layer.

`:core:model` is the direct Android counterpart of the Swift skill's independent Domain boundary.
An optional `:domain:<area>` is Google's use-case layer and may depend on repository APIs; that edge
never permits `:core:model` to depend on data modules.

### Shared UI

<!-- kotlin-suite:KOTLIN-SHARED-UI -->

Keep UI local to a Feature first. Create a feature-family shared module only for one cohesive
presentation concept used by several Features. Use an app-wide `:core:designsystem`/`:core:ui`
module for design tokens, components, adaptive primitives, formatters, accessibility helpers, and
localized resources used broadly. Shared UI owns no workflows, repositories, routes, SDK adapters,
or unrelated conveniences.

## Frameworks and Datasources

Prefer distinct responsibilities even when packages inside one Gradle module are sufficient. A
legacy `:infrastructure` module may combine them only when splitting would enforce no meaningful
boundary; document both responsibilities and retain the same forbidden edges.

### Frameworks

Frameworks wrap low-level Android or third-party technology generically: HTTP engines, database
plumbing, file access, location, analytics, ML, codecs, delegates, and SDK-safe helpers. A Framework
API contains no application vocabulary and performs no mapping into Domain values. It depends only
on Kotlin/Android and the exact technology it wraps, plus narrow construction tooling such as Hilt
when the repository deliberately keeps owner-local bindings there. It never imports Domain,
Datasources, Features, Navigation, or App composition.

Google commonly calls these **common/core modules**, such as `:core:network`. A repository may use
`:framework:http` or `:http-framework` when explicit layer naming is clearer. Classify by
responsibility, not prefix. Do not wrap Retrofit, Room, Firebase, or another SDK merely to populate
the Frameworks layer: when an API necessarily contains Profile, Trip, or other application concepts,
keep that adapter in its owning data module.

### Datasources and Google's data layer

Datasources implement concrete access to application data and correspond to Google's data layer.
Organize Gradle modules by coherent data domain—for example `:data:profile`—not by transport. A data
module normally owns a repository and its internal remote/local data sources, DTOs/entities, mapping,
main-safety, conflict resolution, and source-of-truth policy. The repository:

- is the entry point from higher layers;
- coordinates zero or more data sources;
- exposes immutable application values through suspending functions or `Flow`;
- maps transport/storage models and failures to application-facing values;
- owns dispatcher switching for blocking or CPU-heavy work;
- normally treats local persistence as canonical for offline-first data.

A Datasources module may depend on Domain and the exact Frameworks modules it uses. When a generic
wrapper would add no value, it may instead own the vendor SDK directly at its lowest
application-specific adapter; record that as an intentionally inline Framework edge. It never
depends on Features, Navigation, or App composition. Avoid sibling data-module edges by default; if
an aggregate repository legitimately depends on another repository as Google permits, record the
aggregate owner and prove the graph remains acyclic.

Keep one `:data:<area>` module when `internal` visibility sufficiently hides implementations. Split
`:data:<area>:api` from `:data:<area>:impl` only for a meaningful compiler-enforced contract,
multiple implementations, independent ownership/reuse, or build isolation. Do not split remote and
cache modules merely because one repository coordinates two technologies.

## Features and Navigation

### Features

A Feature owns one independently meaningful user capability or related flow: input, semantic
outcomes, screen state, workflow, pure projections, effect requirements, UI, Android lifecycle
adaptation, and owner-local tests. Follow unidirectional data flow: a screen `ViewModel` exposes
immutable `StateFlow`; a Route obtains and lifecycle-collects it; a stateless Screen receives state
and semantic callbacks.

#### Feature and subfeature packages

Organize a Feature vertically by product owner. A module with several independently meaningful
capabilities, workflows, or screens must give each one a named subfeature package; do not pool their
machines or presentation in Feature-wide horizontal buckets. A single cohesive Feature may use its
Feature package as the owner root without adding a redundant same-named subfeature.

Use `feature.<area>[.<subfeature>]` as the owner root and apply the packages that match its real
responsibilities:

| Owner kind | Required shape |
| --- | --- |
| Stateful Compose owner | `statemachine` with the four canonical machine files, plus `views` with `<Owner>RootScreen.kt` |
| Stateful non-UI workflow | `statemachine` with the four canonical machine files; omit an empty `views` package |
| Stateless Compose owner | `views` with `<Owner>RootScreen.kt`; do not create a machine or `statemachine` package |

The four canonical files are `<Owner>States.kt`, `<Owner>Events.kt`, `<Owner>Outputs.kt`, and
`<Owner>StateMachine.kt`. Keep owner-local guards, policies, capabilities, factories, controllers,
and effects beside those files in `statemachine`; never move Compose, Android presentation, or
navigation declarations there. When a workflow has no output declarations, retain a package-only
`<Owner>Outputs.kt` rather than inventing a fake output or empty machine.

Keep Route, ViewModel, Screen, UI projections, operation identifiers, previews, and Compose-only
helpers in `views`. `<Owner>RootScreen.kt` is the discoverable UI entry source and may contain the
stable owner Route/Screen functions required by existing callers. A `statemachine` package must
never import its sibling `views`; `views` may depend on the owner-local machine.

Only contracts genuinely shared across machine, views, navigation, or App composition remain at
the owner root. Keep other declarations in their owning package, mirror the owner package in unit
and instrumented tests, and avoid generic `ui`, `viewmodel`, `machine`, `api`, `impl`, `common`, or
`util` buckets. Enforce the selected owner inventory, canonical filenames, package/path agreement,
RootScreen presence, stateless exclusions, and forbidden machine-to-view edge with positive and
negative architecture checks.

Google permits a Feature/ViewModel to depend directly on a repository API or on an optional domain
use case. Use either when that public seam is already narrow. For stronger Swift-aligned isolation,
let the Feature own a suspending function or small capability and adapt the repository to it in App
composition. In every form, a Feature must not import a concrete repository/data source, Framework,
DAO, Retrofit service, Firebase client, dispatcher provider, Hilt component, or service locator.

### Navigation

Navigation owns route/deep-link interpretation, destination lifetime, root graph coordination, and
mapping Feature outcomes to destinations. Prefer typed routes when supported. Pass identifiers or
irretrievable transient values; let the destination load and validate private context. Features emit
semantic outcomes rather than another Feature's route.

Google normally keeps simple destination declarations in a Feature and root navigation in `:app`.
Preserve Navigation as an explicit logical layer, but create `:navigation:<area>` only when its
contract, reuse, ownership, or build isolation is independently meaningful.

## Gradle modules by scale

In a small app, layers can be packages inside `:app`:

```text
com.example.app/
├── domain
├── framework/http
├── data/profile
├── feature/profile
├── navigation
└── app
```

For a typical growing app, prefer Google's cohesive feature/data/common breakdown:

```text
:app
:feature:profile
:data:profile                   # Datasources/data layer
:core:model                     # Domain values
:core:designsystem              # Shared UI
:core:network                   # Frameworks, when genuinely generic
```

Add stricter modules only where they buy a real boundary:

```text
:domain:profile                 # optional Google domain/use-case layer
:data:profile:api               # optional repository contract split
:data:profile:impl              # Datasources implementation
:navigation:profile             # optional independent Navigation owner
:framework:http                 # alternative naming for a generic Framework
```

A representative allowed graph is:

```text
# A -> B means A may declare a Gradle dependency on B.
:core:network -> OkHttp/Ktor                         # Frameworks
:data:profile:api -> :core:model
:data:profile:impl -> :data:profile:api
:data:profile:impl -> :core:model + :core:network   # Datasources
:navigation:profile -> :feature:profile
:app -> :feature:profile + :navigation:profile + :data:profile:impl

# Choose the narrowest one of these Feature consumption paths:
:feature:profile -> :data:profile:api                # direct repository, Google default
:feature:profile -> :domain:profile -> :data:profile:api
:feature:profile -> :core:model                      # feature-owned port; App adapts it
```

Manual composition may also depend directly on the exact Framework module it constructs. With Hilt,
that edge can remain transitive through the implementation module while the app still includes and
selects the complete generated graph.

For every module record `owns`, `may depend on`, `must not depend on`, `public seam`, `lifetime
owner`, `source-of-truth owner`, and `test owner`. Reject cycles. A reverse edge usually means an
abstraction or composition responsibility belongs elsewhere.

## Application composition and dependency injection

<!-- kotlin-suite:KOTLIN-COMPOSITION -->

DI is a composition mechanism, not an additional architecture layer. The App boundary owns
process-level assembly, root navigation, build-variant implementation selection, and long-lived
lifetimes. Manual constructor injection is valid for small apps and tests. Hilt is Google's
recommended library for complex Android apps; Hilt modules are not Gradle modules.

Prefer constructor injection. Keep `@Binds` with the implementation it binds and `@Provides` with
the Frameworks or Datasources implementation that owns third-party construction. Keep app-specific
configuration and any adapter that must know both a feature-owned port and a repository API in
`:app`. Do not create a central `:di` umbrella that makes every implementation visible, and never
use a global service locator.

For a destination-owned workflow, inject a feature-owned machine factory into the
`@HiltViewModel`; the ViewModel invokes `create(viewModelScope, runtimeInput)` exactly once. Supply
runtime destination identity with `@AssistedInject`/`@AssistedFactory` and obtain the ViewModel from
the destination Route with assisted `hiltViewModel`, including a stable key when identity requires
one. Hilt constructs the machine factory and its capabilities—it never binds a destination
`StateMachineFlow`, a `CoroutineScope`, or a prebuilt ViewModel. Do not pass a manual
`ViewModelProvider.Factory` through Navigation or Compose.

Manual composition constructs Frameworks, then Datasources, then adapts their operations to Feature
ports. With Hilt, owner-local bindings generate the same object graph; the app still chooses which
implementation modules and variants enter that graph. Feature modules compile only against their
repository/use-case/capability seams, never against the concrete graph.

Scope a dependency only to its real lifetime. `@Singleton` means one instance in the application
component, not “convenient.” Destination state belongs to a ViewModel or navigation owner; work that
must survive a screen may require a repository-owned external scope or WorkManager. Hilt selects and
constructs implementations; it must not absorb feature policy or effect sequencing.

Hilt's app module must reach all owner-local bindings through its Gradle dependency graph. Play
dynamic-feature modules require Hilt entry points and Dagger component dependencies because their
Gradle relationship is reversed; do not weaken ordinary module boundaries to work around that case.

The compiled fixture uses an Android library named `:app-composition` as its application-integration
stand-in: it selects the HTTP adapter and bridges the repository API to the feature-owned effect
port while Datasources and Feature keep their own Hilt bindings and generated owners. The
`:consumer-smoke` module proves that a downstream destination caller needs only the published
Navigation seam—not an application composition object or ViewModel factory. A production Android
application normally places these integration bindings in its executable `:app` module.

## Visibility and dependency sanity

Use the narrowest Kotlin visibility:

| Visibility | Use |
| --- | --- |
| `private` | one declaration/file owns the detail |
| `internal` | collaboration inside one Gradle module |
| `public` | a real cross-module or library API requires it |

For every production module verify:

- each imported external/module API has a direct declared dependency;
- `api` is used only when a dependency is intentionally part of the consumer ABI;
- every declared dependency is used or documented as a required plugin/codegen/runtime edge;
- Frameworks contain no application vocabulary or application-layer dependency;
- Datasources depend only on Domain, exact Frameworks or an intentional owner-local SDK edge, and
  explicitly justified data APIs;
- Features and Navigation do not depend on Frameworks or Datasources implementations;
- repository implementations and DTO/entity/SDK failures are not public to features;
- DI bindings preserve rather than bypass the allowed Gradle graph;
- test fixtures do not leak into production source sets;
- build variants do not introduce forbidden reverse edges;
- convention plugins centralize build policy without becoming application-layer dependency hubs.

Use version catalogs and dependency locking/verification when the repository adopts them. Do not
silently change a dynamic/range/exact/version-catalog policy as part of unrelated work.

## Third-party dependency policy

<!-- kotlin-suite:KOTLIN-THIRD-PARTY -->

Put Android/vendor SDKs at the lowest owning edge: a Framework when the wrapper is genuinely generic,
otherwise the Datasources implementation whose application-specific adapter uses it. Keep Compose,
AndroidX, coroutines, Kotlin State Machine, Hilt, and test libraries in their explicit owners. Any
other new production dependency—and any plugin, version, repository, pin policy, or selected version
change—requires architecture-owned approval before editing when the repository or user requires
that authority. Carry the exact approved identity and scope in the current lifecycle handoff when
one exists.

## Resources, tests, and Android components

Resources live with the module that interprets them. Update every supported locale for changed
user-facing UI, accessibility, notifications, widgets, shortcuts, tiles, metadata, and plurals.
Avoid resource-name collisions and accidental `transitiveRClass` assumptions; follow the live AGP
configuration.

Keep unit tests with their owner. Use `test` for local JVM tests, `androidTest` for device/framework
integration, and test fixtures only through deliberate Gradle capabilities. Reserve app-level tests
for root DI/navigation, end-to-end behavior, and architecture guardrails.

Activities, services, receivers, providers, widgets, workers, and dynamic features are separate
lifecycle/entry boundaries. Give each the smallest dependency graph and validate manifest, exported
state, permissions, process/lifetime, and restoration behavior.

## Validation

Validate in expanding rings:

1. inspect `projects`, dependencies, variants, version catalogs, and dependency locks;
2. compile/test every changed module with its real Kotlin/AGP settings;
3. run guardrails for forbidden edges, visibility, source sets, resources, and test ownership;
4. assemble relevant app variants and run integration/instrumented tests;
5. observe affected emulator/device flows, process recreation, background work, or entry points.

An app assembly does not prove the intended module boundary or runtime behavior.
