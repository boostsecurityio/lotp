---
title: deno
tags:
  - config-file
  - eval-js
references:
  - https://docs.deno.com/runtime/fundamentals/configuration/
  - https://docs.deno.com/runtime/reference/cli/test/
files: [deno.json, deno.jsonc, package.json]
---

`deno` is a modern JavaScript runtime with solid security defaults.

## Tasks

Invocations of `deno task <task>` look for corresponding tasks configured in `deno.json`, `deno.jsonc` or `package.json` (as scripts in the latter case) and execute them under the current shell. This is akin to what `npm` does with scripts.

## Test cases

When running `deno test`, `deno` looks for and executes any file that matches one of the following glob patterns: `{*_,*.,}test.{js,mjs,ts,mts,jsx,tsx}` and `**/__tests__/**`.

By default, these tests are sandboxed under typical `deno` restrictions, but depending on the pipeline, there may be interesting privileges configured that could be used.