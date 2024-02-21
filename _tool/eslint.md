---
title: eslint
tags:
- cli
- config-file
- eval-js
references:
- https://eslint.org/docs/latest/use/configure/configuration-files
files: [eslint.config.js, eslint.config.mjs, eslint.config.cjs, .eslintrc.js, .eslintrc.cjs]
purl: pkg:npm/eslint
---

Eslint's uses a JavaScript configuration file. 

In recent Eslint versions, it will load any of the following configuration files in the following order depending on the package.json module type:
- `eslint.config.js`
- `eslint.config.mjs`
- `eslint.config.cjs`


In Eslint <9.0.0, it will load the first found configuration file in the following order: 
1. `.eslintrc.js`
2. `.eslintrc.cjs`
3. `.eslintrc.yaml`
4. `.eslintrc.yml`
5. `.eslintrc.json`
6. `package.json`

