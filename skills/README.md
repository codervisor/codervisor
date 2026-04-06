# Codervisor Skills

Public agent skills for Codervisor tools. Install via [`npx skills`](https://github.com/anthropics/claude-code).

## Available Skills

| Skill | Install | Description |
|-------|---------|-------------|
| `leanspec` | `npx skills add codervisor/skills@leanspec` | Spec-Driven Development methodology for LeanSpec projects |

## Install a Skill

```bash
# Install a specific skill
npx skills add codervisor/skills@leanspec

# Or install all skills from this repo
npx skills add codervisor/skills
```

## What is LeanSpec?

[LeanSpec](https://github.com/codervisor/leanspec) is a spec-driven development tool for AI-assisted projects. The `leanspec` skill teaches AI agents the SDD workflow: how to discover, create, refine, implement, and verify specs using the `leanspec` CLI.

## Contributing

Skills live under `.agents/skills/<name>/`. Each skill has a `SKILL.md` with frontmatter and optional `references/` files.

## License

MIT
