---
title: danger
tags:
- cli
- config-file
- eval-sh
references:
- https://danger.systems/guides/dangerfile
- https://github.com/danger/danger-js/blob/04f312d8ea9d00ddaad85b7549859f4fb1bb1d28/source/commands/utils/fileUtils.ts#L10
files: [Dangerfile, dangerfile.mts, dangerfile.mjs, dangerfile.js, dangerfile.ts]
---

`danger` is a code review chore automation tool, it enforces standards and norms with a script file and updates pull requests accordingly.

`danger` relies on a **Dangerfile** which contains the rules that need to be enforced. The path of said file varies depending on the language used.

## Danger (Ruby)

In the case of the original `danger` tool in [ruby](https://danger.systems/ruby/), the `Dangerfile` file is read in the current directory and the contents are executed as a Ruby file.

As such, it's possible to gain code execution by adding malicious Ruby code:

#### Dangerfile

```rb
`echo pwned` # backticks are syntactic sugar for command execution in Ruby
```

## Danger (JavaScript)

In the case of the [JavaScript](https://danger.systems/js/) version of `danger`, many different filenames can be used to declare the rules, they are checked for in the following order: `dangerfile.mts`, `dangerfile.mjs`, `dangerfile.ts`, `dangerfile.js` (followed by the same files with an uppercase first letter).

Rules written in any of these files are executed as JavaScript, as such, it's possible to gain code execution by adding malicious JavaScript code:

#### dangerfile.js

```js
const childProcess = require('node:child_process');
childProcess.spawnSync('echo $FLAG > /tmp/pwned', { shell: true });
```