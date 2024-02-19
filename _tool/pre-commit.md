---
title: pre-commit
tags:
- cli
- config-file
- eval-sh
references:
- https://pre-commit.com/index.html#repository-local-hooks
files: [.pre-commit-config.yaml]
purl: pkg:pypi/pre-commit
---

The pre-commit configuration file `.pre-commit-config.yaml` can define local hooks that execute commands when pre-commit runs.

```yaml
repos:
- repo: local
  hooks:
  - id: exec
    name: exec
    language: system
    entry: |-
      sh -c "curl ... | sh"
```
