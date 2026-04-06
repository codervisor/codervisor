---
name: railway
description: Access Railway deployments, logs, and environment variables. Use when asked to check deployment status, view service logs, inspect or update environment variables, redeploy a service, or diagnose production issues on Railway.
---

# Railway Skill

Interact with Railway services using the `railway` CLI. Authentication is via the `RAILWAY_TOKEN` environment variable — no login step needed.

## Prerequisites

- `RAILWAY_TOKEN` must be set in the environment (set in Railway dashboard → project → Variables)
- `railway` CLI must be installed (`npm install -g @railway/cli`)
- Identify the target project and service before running commands

## Core Commands

### View logs

```bash
# Stream live logs for a service
railway logs --service <service-name>

# Show recent logs (non-streaming)
railway logs --service <service-name> --tail 100
```

For Rust services, combine with `RUST_LOG=debug` in environment variables for verbose output.

### Deployment status

```bash
# Status of the linked project
railway status

# List recent deployments
railway deployments
```

### Environment variables

```bash
# List all variables for a service
railway variables --service <service-name>

# Set a variable
railway variables set KEY=VALUE --service <service-name>

# Delete a variable
railway variables delete KEY --service <service-name>
```

> **Caution**: Setting variables triggers a redeploy. Confirm with the user before changing production variables.

### Redeploy

```bash
# Trigger a redeploy of the latest deployment
railway redeploy --service <service-name>
```

### Link a project (run once to set project context)

```bash
railway link --project <project-id>
```

After linking, `--project` flags are optional for subsequent commands.

## Workflow: Diagnosing a Production Issue

1. Check deployment status:
   ```bash
   railway status
   ```
2. View recent logs:
   ```bash
   railway logs --service <name> --tail 200
   ```
3. If a Rust service — increase verbosity without redeploying:
   ```bash
   railway variables set RUST_LOG=debug --service <name>
   ```
   Then tail logs again to see detailed output.
4. Once diagnosed, restore log level:
   ```bash
   railway variables set RUST_LOG=info --service <name>
   ```

## Codervisor Services

| Service | Stack | Notes |
|---------|-------|-------|
| `stiglab-server` | Rust | Control plane; uses `RUST_LOG` |
| `stiglab-agent` | Rust | Node agent; uses `RUST_LOG` |
| `telegramable` | Node.js | Telegram proxy; env vars control timeouts |

## Tips

- Always confirm service name spelling — Railway is case-sensitive
- `railway logs` streams indefinitely; press Ctrl+C to stop
- Variable changes trigger redeployment — warn the user before setting in production
- Use `--json` flag on most commands for machine-readable output
