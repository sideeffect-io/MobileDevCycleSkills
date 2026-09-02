# Missing Specialist Installation

Use this reference only when the specialist overlay selected in `SKILL.md` is not locally available.

1. Name the missing skill and the confidence or evidence it would add. Continue without it only when
   the Architect contract can still be satisfied; otherwise stop the affected slice and route the
   missing capability to the root.
2. Never install or enable a skill or plugin without explicit user authorization.
3. After authorization, use the verified distribution channel:
   - Install **Build iOS Apps** from Codex Plugins for `ios-app-intents`, `ios-debugger-agent`,
     `ios-ettrace-performance`, or `ios-memgraph-leaks`.
   - Invoke `$skill-installer` with the exact GitHub skill URL for `swift-concurrency`
     (`https://github.com/AvdLee/Swift-Concurrency-Agent-Skill/tree/main/skills/swift-concurrency`),
     `swiftui-expert`
     (`https://github.com/sideeffect-io/swift-expert-skill/tree/main/swiftui-expert-skill`), or
     `mobile-ios-design`
     (`https://github.com/wshobson/agents/tree/main/plugins/ui-design/skills/mobile-ios-design`).
   - For another focused SwiftUI skill, verify its owning plugin or repository first, then use Codex
     Plugins or `$skill-installer` with that exact source. Do not guess a source or assume a bare skill
     id exists in the curated catalog.
4. Re-read the installed `SKILL.md` frontmatter and load the exact exposed skill name on the next turn.
   If Codex does not detect it, restart Codex.
