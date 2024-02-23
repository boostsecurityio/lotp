---
title: mkdocs
tags:
  - cli
  - config-file
  - eval-py
references: 
- https://www.mkdocs.org/user-guide/configuration/#hooks
files: [mkdocs.yml,mkdocs.yaml]
---

`mkdocs` is a static site generator focused on building project documentation, utilizing markdown files and a single YAML configuration file (`mkdocs.yml`). With version 1.4, `mkdocs` introduced hooks within its plugin system, allowing the execution of custom Python code at various points of the build process, enhancing flexibility and customization.

These hooks enable actions such as modifying the `mkdocs` configuration, altering the content before it's rendered, or executing custom scripts, directly impacting the build and deployment phases of the documentation.

Typically the exploit chain would start with `mkdocs build` (or another command like `deploy` or `serve`).

## `mkdocs.yml`

```yaml
hooks:
- poc.py
```

## `poc.py`

```py
import os
os.system('id')
```
