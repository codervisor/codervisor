# codervisor

Shared standards, CI workflows, hooks, and conventions for all codervisor repositories. This is the **remote template repo** — the single source of truth that child repos reference.

Child repos don't copy these files manually. They either:
- **Bootstrap once** with a one-liner that pulls everything in
- **Call reusable CI workflows** defined here (zero duplication)
- **Get published to** via `npm run publish` when standards change

## Quick start — onboarding a child repo

```sh
cd your-child-repo
curl -fsSL https://raw.githubusercontent.com/codervisor/codervisor/main/scripts/bootstrap.sh | bash
git add -A && git commit -m "chore: bootstrap shared config from codervisor"
```

This auto-detects your project type (Rust/TypeScript/Lean) and pulls in:
- `CLAUDE.md` — coding standards
- `CONTRIBUTING.md` — development SOP
- `.github/workflows/ci.yml` — CI that calls reusable workflows from this repo
- `hooks/commit-msg` — conventional commit enforcement
- `.claude/settings.json` — Claude Code session hooks

## Child projects

| Project | Stack | Description |
|---------|-------|-------------|
| [stiglab](https://github.com/codervisor/stiglab) | Rust + TS | Distributed AI agent session orchestration |
| [synodic](https://github.com/codervisor/synodic) | TypeScript | AI harness governance framework |
| [telegramable](https://github.com/codervisor/telegramable) | TypeScript | Telegram-first AI agent proxy |
| [ising](https://github.com/codervisor/ising) | Rust | Code graph analysis engine |
| [skills](https://github.com/codervisor/skills) | TOML / MD | Shared Claude Code skills |
| [lean-spec](https://github.com/codervisor/lean-spec) | Lean 4 | Formal specification framework |

## How it works

### Reusable CI workflows

Child repos have a thin `ci.yml` that calls workflows defined here:

```yaml
# In child repo: .github/workflows/ci.yml
jobs:
  ci:
    uses: codervisor/codervisor/.github/workflows/ci-rust.yml@main
```

The actual CI logic (rustfmt, clippy, cargo test, npm ci, etc.) lives in this repo. Update it once — all children inherit the change on their next CI run.

### Shared files (CLAUDE.md, CONTRIBUTING.md, hooks)

These are static files copied into child repos. They can be updated by:
1. **Re-running bootstrap**: `curl ... | bash` in the child repo
2. **Publishing from here**: `npm run publish` opens PRs in all children
3. **CI auto-sync**: On merge to `main`, the `sync-to-children` workflow opens PRs

## Directory layout

```
codervisor/
├── .meta                          # project manifest (name → remote URL)
├── .github/workflows/
│   ├── ci-rust.yml                # reusable CI for Rust (called by children)
│   ├── ci-typescript.yml          # reusable CI for TypeScript (called by children)
│   └── sync-to-children.yml      # auto-sync on merge to main
├── templates/callers/             # thin CI wrappers children copy into their repo
│   ├── ci.yml.rust                # calls ci-rust.yml from this repo
│   └── ci.yml.typescript          # calls ci-typescript.yml from this repo
├── hooks/                         # shared hooks (copied into children)
│   ├── commit-msg                 # conventional commit enforcement
│   └── .claude/settings.json      # Claude Code session-start hook
├── scripts/
│   ├── bootstrap.sh               # one-liner setup for child repos
│   ├── publish-to-children.sh     # push shared config to children via gh CLI
│   ├── sync-ci.js                 # copies caller workflows into local children
│   ├── sync-hooks.js              # copies hooks into local children
│   └── sync-claude.js             # copies CLAUDE.md + CONTRIBUTING.md into children
├── CLAUDE.md                      # shared coding standards
├── CONTRIBUTING.md                # development SOP
└── package.json                   # npm scripts
```

## npm scripts

### Publishing to child repos

| Command | What it does |
|---------|-------------|
| `npm run publish` | Open PRs in all child repos with latest shared config |
| `npm run publish:direct` | Push directly to `main` in all children (no PR) |
| `npm run publish -- synodic` | Publish to a single child repo |

### Local sync (if children are cloned locally)

| Command | What it does |
|---------|-------------|
| `npm run sync:ci` | Copy CI caller workflows into each local child |
| `npm run sync:hooks` | Copy hooks into each local child |
| `npm run sync:claude` | Copy CLAUDE.md + CONTRIBUTING.md into each local child |
| `npm run sync:all` | Run all three sync scripts |

### Subtree operations (optional, for monorepo-style work)

| Command | What it does |
|---------|-------------|
| `npm run subtree:add` | Add all children as git subtrees |
| `npm run subtree:pull` | Pull latest from child remotes |
| `npm run subtree:push` | Push changes back to child remotes |

## Updating shared standards

1. Edit the relevant file in this repo (CLAUDE.md, CI workflow, hooks, etc.)
2. Commit and push to `main`
3. Publish to children:
   ```sh
   npm run publish          # opens PRs in all child repos
   ```
   Or let the `sync-to-children` CI workflow do it automatically.

## Adding a new child repo

1. Add to `.meta`:
   ```json
   "my-repo": "git@github.com:codervisor/my-repo.git"
   ```
2. Bootstrap the child:
   ```sh
   cd my-repo
   curl -fsSL https://raw.githubusercontent.com/codervisor/codervisor/main/scripts/bootstrap.sh | bash
   ```
