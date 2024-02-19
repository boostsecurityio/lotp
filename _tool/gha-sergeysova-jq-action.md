---
title: sergeysova/jq-action
tags:
- github-actions
- injection
- eval-sh
references:
- https://github.com/sergeysova/jq-action/
sinks: [inputs.cmd]
purl: pkg:githubactions/sergeysova/jq-action
---

The input `cmd` is evaluated as bash. The value interpolated may contain user-input and execute commands.

```yaml{% raw %}
steps:
- name: jq
  uses: sergeysova/jq-action@v2
  with:
    cmd: |
      jq '.[] | select(.name == "${{ github.event.inputs.name }}")' input.json
      
{% endraw %}```

