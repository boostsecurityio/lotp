---
title: prettier
tags:
- cli
- config-file
- eval-js
references:
- https://prettier.io/docs/en/configuration.html
files: ['.prettierrc.js', '.prettierrc.config.js']
purl: pkg:npm/prettier
---

Prettier's config uses JavaScript. If Prettier runs on untrusted code without a config file or the config file is either
- `.prettierrc.mjs`, `prettier.config.mjs`
- `.prettierrc.cjs`, `prettier.config.cjs`
- `.prettierrc.toml`

Then the configuration file `.prettierrc.js`, `.prettierrc.config.js` has precedence over the other files. 
