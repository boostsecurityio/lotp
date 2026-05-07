---
title: wrangler
tags:
  - cli
  - config-file
  - eval-sh
references:
  - https://developers.cloudflare.com/workers/wrangler/custom-builds/
  - https://developers.cloudflare.com/workers/wrangler/configuration/
  - https://developers.cloudflare.com/workers/wrangler/commands/
  - https://github.com/cloudflare/wrangler-action
files: [wrangler.toml, wrangler.json, wrangler.jsonc]
purl: pkg:npm/wrangler
---

`wrangler` is Cloudflare's CLI for Workers. It auto-discovers `wrangler.toml`, `wrangler.json` or `wrangler.jsonc` in the current working directory.

## Custom builds

The `[build].command` field is run via `sh -c` (Linux/macOS) or `cmd` (Windows) before the worker is bundled. The `cwd` and `watch_dir` fields control where the command runs and which directory triggers a rebuild during `wrangler dev`.

`wrangler.toml`:

```toml
name = "poc"
main = "src/index.js"
compatibility_date = "2024-01-01"

[build]
command = "<arbitrary_shell_command_goes_here>"
cwd = "."
```

`wrangler.jsonc` equivalent:

```jsonc
{
  "name": "poc",
  "main": "src/index.js",
  "compatibility_date": "2024-01-01",
  "build": {
    "command": "<arbitrary_shell_command_goes_here>"
  }
}
```

## Subcommands that fire the build hook

| Command | Auth required | Notes |
| -- | -- | -- |
| `wrangler deploy` | no | hook fires *before* the auth check |
| `wrangler deploy --dry-run` | no | exits 0, useful when no creds are available |
| `wrangler versions upload` | no | same pre-auth fire as `deploy` |
| `wrangler versions upload --dry-run` | no | exits 0 |
| `wrangler dev` | no | fires immediately on startup, then watches `watch_dir` |
| `wrangler types` | no | exits 0, lightest invocation |
| `wrangler publish` (v3 only) | no | deprecated alias of `deploy`; removed in v4 (errors `Unknown argument: publish` before the hook fires) |

Inside the hook, the `WRANGLER_COMMAND` environment variable (wrangler v4+) reflects which subcommand triggered the build (`deploy`, `dev`, `types`, ...).

The following subcommands do **not** read the `[build]` section: `wrangler whoami`, `wrangler secret`, `wrangler kv`, `wrangler tail`, `wrangler triggers deploy`.

## GitHub Actions

`cloudflare/wrangler-action` defaults to `wrangler deploy`, so any workflow using it without overriding `command:` is a sink.
