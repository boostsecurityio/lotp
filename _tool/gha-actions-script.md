---
title: actions/github-script
tags:
- github-actions
- injection
- eval-js
references:
- https://github.com/actions/github-script
sinks: [inputs.script]
purl: pkg:githubactions/actions/github-script
---

The `script` input to the `actions/github-script` action allows you to run a JavaScript. 

A GitHub Actions expression that injects into the script could allow the execution of arbitrary JavaScript:
```yaml{% raw %}
steps:
- uses: actions/github-script@v7
  with:
    script: |
      console.log('Error issue title "${{ github.event.issue.title }}" does not match expected format.');{% endraw %}
```

The action may also be used to load a local file from the repository and executes it:
```yaml
steps:
- uses: actions/github-script@v7
  with:
    script: |
      const script = require('./path/to/script.js')
      console.log(script({github, context}))
```
