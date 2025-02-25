---
title: actions/setup-node
tags:
  - config-file
  - eval-js
references: 
- https://github.com/actions/setup-node
files: [.yarnrc.yml]
---

`actions/setup-node` is used to set up a node environment. It supports a cache flag that calls `npm` or `yarn` under the hood to cache dependencies.

```yaml
    - uses: actions/setup-node@v4
      with:
        cache: yarn
```

Then see [yarn](https://boostsecurityio.github.io/lotp/tool/yarn). Modification to `poc.js` can make this step pass without error.
