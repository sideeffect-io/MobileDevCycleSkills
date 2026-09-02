# Architecture Layers and SwiftPM

<!-- swift-suite:SWIFT-LAYERS -->

## Contents

- Compiler-enforced boundaries
- Default layer responsibilities
- Frameworks and Datasources split
- Target design
- Access control and API surfaces
- Import and dependency sanity
- Resources, tests, and extensions
- Validation

## Compiler-enforced boundaries

A directory communicates intent; a SwiftPM target enforces it. A target may import only declared
dependencies, and another target sees only its exported API. Use targets for stable responsibilities
whose separation prevents a meaningful class of mistake. Avoid both a monolith that exposes every
implementation detail and micro-targets whose only purpose is moving files.

A package is a distribution and resolution unit. A target is the compilation boundary. Aggregate
products may simplify top-level linkage, but they do not replace exact target dependencies.

## Default layer responsibilities

### Domain

Own business vocabulary, identifiers, validated values, finite failures, and pure policies. Depend
on the standard library and value-oriented Foundation APIs only when needed. Do not import UI,
persistence, networking, vendor SDKs, composition code, or feature modules. Inject clocks, UUIDs,
locale, calendars, permissions, and external reads whenever they affect a decision.

### Shared UI

<!-- swift-suite:SWIFT-SHARED-UI -->

Keep UI local to its Feature first. Create a feature-family shared target only when several Feature
targets share one cohesive presentation concept and Navigation does not consume it. Use `SharedUI`
only for app-wide primitives, design tokens, formatters, accessibility helpers, and localized
resources consumed across Features and Navigation. Shared targets do not own workflows,
repositories, routes, SDK adapters, or unrelated convenience views; none is a dumping ground.

### Frameworks

**Frameworks** wrap low-level technology generically. Use a distinct target when an SDK dependency
or risk boundary satisfies the target criteria below; do not split cohesive wrappers merely to
mirror SDK names. Frameworks own generic DAOs, clients, codecs, delegates, and helpers without
application vocabulary. A Frameworks target depends only on the platform framework or third-party
SDK it wraps. It never depends on Domain, Datasources, Features, Navigation, App Composition, or
another application layer, and it does not map values into app entities. No need to suffix the targets with "<Target>Framework".

### Datasources

**Datasources** implement concrete access to application data. Expose one target per data domain,
such as TripsDataSource, FamilyDataSource, or ProfileDataSource. A Datasources target may depend on
Domain and only the exact Frameworks targets it uses. It converts DTOs, managed objects, SDK errors,
and callbacks into domain entities and finite domain-shaped results. It never depends on Features,
Navigation, or App Composition, and one data-domain target does not coordinate another.

Each Datasources target can expose services or repositories that internally take closures or capability structs as init parameters (for unit testing purpose) and publicly expose a `.live` implementation relying on Frameworks and other production dependencies.

Organize Datasources by data ownership, not transport. A single `ProfileDataSource` may coordinate
HTTP and CoreData Frameworks for the Profile data domain; do not create ProfileRemote/ProfileCache
targets solely because two storage technologies are involved. Split only when the data domains,
lifecycles, public seams, and test owners are independently meaningful.

### Features

Give an independently meaningful user capability its own target when the boundary meets the target
criteria below; a screen or form step is not automatically a target. A feature owns its input, semantic
outcomes, workflow, pure projections, effect requirements, root UI, local presentation, and
target-local tests. It depends on Domain, SharedUI, SwiftUI when needed, the minimal
SwiftStateMachine products, and explicitly composed child features. It never imports Frameworks,
Datasources, a combined Infrastructure fallback, or top-level navigation vocabulary. Its views,
states, events, outputs, and machine contain no
concrete SDK, Frameworks, Datasources, DAO, live repository, or adapter implementation.

The feature owns each output port as an `@Sendable` closure or cohesive `Sendable` capability struct.
An output may orchestrate injected operations and translate success, finite failure, and cancellation
into events; it does not construct or discover the concrete implementation that performs the work.

### Navigation

Own launch, tabs, route values, deep-link interpretation, feature-root presentation, and semantic
outcome orchestration. Depend on exact feature modules and dependency-light routing contracts. Do
not retrieve, mutate, or adapt Frameworks/Datasources data on behalf of a child feature.

### App and extensions

<!-- swift-suite:SWIFT-COMPOSITION -->

Own process/scene lifetime and final assembly. Every executable process has exactly one composition
root. The app and each extension use separate minimal roots and assemble only the graph required by
that process. Construct the required generic Frameworks wrappers,
use them to construct data-domain Datasources, and adapt those concrete operations to feature-owned
closures or capability structs. Retain intentional singletons, inject state-machine factories, and
connect entry points. This is the only normal boundary where multiple otherwise independent layers
meet. Extensions receive their own composition root and the smallest graph their process requires.

Composition chooses concrete providers and lifetimes; it does not absorb feature use-case sequencing,
cancellation decisions, or result-to-event mapping. Those remain in the feature-owned output that
orchestrates the injected operations.

For example, composition may create a generic CoreData DAO from `CoreDataFramework`, pass it to
`TripsDataSource`, then close over `TripsDataSource.loadTrips` when constructing the feature-owned
`LoadTripsOutput`. Neither the feature nor its state machine imports either concrete target.

## Target design

Create a target when all are true:

1. It has one stable responsibility and reason to change.
2. Its dependency set differs meaningfully from its neighbors.
3. It can expose a narrow, coherent public seam.
4. It can build and test independently.
5. The boundary rejects a real forbidden dependency or ownership leak.

For each target, record `owns`, `may depend on`, `must not depend on`, `public seam`, `lifetime
owner`, and `test owner`. Reject cycles. A required reverse edge usually means a contract or
composition responsibility is in the wrong layer.

Retire or merge a target when it no longer has a distinct dependency set, independently meaningful
owner, narrow seam, or forbidden edge to reject. Target count is inventory, not evidence of quality.

Prefer unsuffixed domain names such as `TripEditor`, `Persistence`, and `AppNavigation`. Add a
qualifier only to resolve a real ambiguity. Do not create umbrella source modules that make all
features or adapters visible to one another.

## Access control and API surfaces

Choose the narrowest access that satisfies a demonstrated consumer:

| Access | Use |
| --- | --- |
| `private` | One declaration or extension owns the detail |
| `fileprivate` | Separate types in one file intentionally share the detail |
| `internal` | Multiple files in one target collaborate |
| `package` | Multiple targets in one package share a deliberate non-product seam |
| `public` | A different module must compile against the declaration |

Public API is a maintenance commitment. Expose domain values, feature roots, minimal input/outcome
contracts, capability initializers, and factory types only when an actual target consumes them.
Keep concrete workflow states/events, DSL vocabulary, guards, cancellation predicates, DTOs, SDK
errors, storage models, and helper functions non-public. Do not make setters public when consumers
only read. Avoid `open` unless subclassing outside the module is a designed extension point.

Use `@testable import` for tests that intentionally inspect internal behavior. A test is not a
reason to publish an implementation detail. Avoid underscored attributes as architecture tools.

## Import and dependency sanity

For every production target:

- every imported package module has a direct declared target dependency;
- every declared dependency is used by production code or documented as a required linker/plugin
  edge;
- tests declare their production owner and only the additional test products they use;
- vendor products are declared at the lowest adapter target that imports them;
- Frameworks targets cannot import Domain or any other application layer;
- Datasources targets may import Domain and exact Frameworks targets, but not Features, Navigation,
  App Composition, or sibling data-domain targets;
- feature and navigation sources cannot import SDK, Frameworks, Datasources, or other concrete
  implementation modules;
- Domain cannot import application packages;
- App Composition imports the exact Frameworks and Datasources targets required to assemble live
  feature effects; it does not bypass a Datasource to embed data-domain policy in the app target.

Use explicit `.target(name:)` and `.product(name:package:)` dependencies when ambiguity is possible.
Inspect `Package.resolved` before changing a dependency rule. Pinning strategy is a product/release
decision; never silently move a production consumer from a revision to a branch.

## Third-party dependency policy

<!-- swift-suite:SWIFT-THIRD-PARTY -->

Put SDKs at the owning Framework edge. Repository-configured `SwiftStateMachine` and
`AsyncAlgorithms` products may remain front-facing where the architecture explicitly uses them.
Any other new third-party dependency in Domain, Datasources, Features, or Navigation—and any
pin-policy or selected version/revision change—requires explicit owner approval before editing the
manifest. Record the exact architecture-owned approval object defined by the handoff contract;
implementation must restate that object without normalization.

## Resources, tests, and extensions

Resources move with the target that interprets them and use `Bundle.module`. Localize every changed
user-facing string in every locale supported by the repository, including accessibility,
notifications, App Intents, widgets, Live Activities, exports, metadata, and Info.plist strings.

Prefer a homonymous `<Target>Tests` target when a production target owns independently testable
behavior. Do not add an empty module-load test solely for symmetry; require a reviewed consumer or
build proof for a compile-only seam. Keep unit tests with their owner and reserve the application
bundle for composition, entry-point, guardrail, and genuine multi-module integration tests. Shared
test support must not become an umbrella dependency.

An app extension is another executable boundary. Share pure/domain modules, but inject extension-
appropriate adapters and do not assume the main app's process, container, lifecycle, or resources.

## Validation

Validate in expanding rings:

1. `swift package dump-package` for every changed manifest.
2. Independent build and targeted tests for each changed package/target.
3. Static guardrails for forbidden edges, imports, visibility, target/test ownership, and resources.
4. Top-level Xcode build and relevant integration tests on supported destinations.
5. Runtime validation for affected flows, deep links, restoration, background work, or extensions.

A successful app build does not prove the intended boundary: independently build the modules that
are supposed to remain isolated.
