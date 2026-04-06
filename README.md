# codervisor

Meta-repository that aggregates all active codervisor projects into a single workspace using [`meta`](https://github.com/mateodelnorte/meta). This is the single source of truth for cross-repo governance: shared CI workflows, hooks, scripts, and conventions.

## Quick start

```sh
git clone git@github.com:codervisor/codervisor.git
cd codervisor
npm i -g meta          # one-time global install
npm run clone          # clones all child repos side-by-side
```

## Child projects

| Project | Description |
|---------|-------------|
| [stiglab](https://github.com/codervisor/stiglab) | Distributed AI agent session orchestration platform (Rust + TS) |
| [synodic](https://github.com/codervisor/synodic) | AI harness governance framework |
| [telegramable](https://github.com/codervisor/telegramable) | Telegram-first AI agent proxy |
| [ising](https://github.com/codervisor/ising) | Rust code graph analysis engine |
| [skills](https://github.com/codervisor/skills) | Shared Claude Code skills |
| [lean-spec](https://github.com/codervisor/lean-spec) | Lean specification framework |

## Directory layout

```
codervisor/
├── .meta                       # meta project manifest
├── .github/workflows/          # reusable workflow templates (synced into children)
├── hooks/                      # shared Git / Claude Code hooks (synced into children)
├── scripts/                    # batch operation scripts
│   ├── sync-ci.js              # copies workflows into each child repo
│   └── sync-hooks.js           # copies hooks into each child repo
├── package.json                # npm scripts for meta operations
├── stiglab/                    # ← cloned child repos (git-ignored)
├── synodic/
├── telegramable/
├── ising/
├── skills/
└── lean-spec/
```

## npm scripts

| Command | What it does |
|---------|-------------|
| `npm run clone` | Clone all child repos listed in `.meta` |
| `npm run pull` | Pull latest in every child repo |
| `npm run status` | Show `git status` across all children |
| `npm run sync:ci` | Copy `.github/workflows/*` into each child |
| `npm run sync:hooks` | Copy `hooks/*` into each child |
| `npm run exec -- <cmd>` | Run an arbitrary command in every child |

## Adding a new child repo

1. Add an entry to `.meta` under `"projects"`:
   ```json
   "my-repo": "git@github.com:codervisor/my-repo.git"
   ```
2. Add `my-repo/` to `.gitignore`.
3. Run `npm run clone` to pull it down.

## How sync scripts work

The sync scripts (`scripts/sync-ci.js`, `scripts/sync-hooks.js`) read the `.meta` manifest, iterate over each child project directory, and copy the corresponding files from the meta repo into the child. They skip any child that hasn't been cloned yet. Changes are copied but **not committed** — review diffs in each child before committing.

## Limitations

- **No atomic cross-repo commits.** Each child repo is an independent Git repository; there is no transactional guarantee across them.
- **Per-repo auth still required.** You need push access to each child repo individually.
- **Sync is copy-based.** The sync scripts overwrite destination files; they do not merge. Workflow or hook customizations in children will be replaced on the next sync.
