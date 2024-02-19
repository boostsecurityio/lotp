---
title: roots/issue-closer-action
tags:
- github-actions
- injection
- eval-js
references:
- https://github.com/roots/issue-closer-action
sinks: [inputs.pr-close-message, inputs.issue-close-message]
purl: pkg:githubactions/roots/issue-closer-action
---

By design, the inputs `pr-close-message` and `issue-close-message` are interpolated into a JavaScript template string that is evaluated to render the message template. If the workflow interpolates user input from a GitHub Actions expression into the message, it may be possible to escape out of the template string or add additional JavaScript expressions (ie: `${...}`).

```yaml{% raw %}
steps:
- name: Autoclose issues
  uses: roots/issue-closer@v1.1
  with:
    repo-token: ${{ secrets.GITHUB_TOKEN }}
    issue-close-message: |
      @${issue.user.login} your issue "${{ github.event.issue.title }}" was automatically closed because it did not follow the issue template
    issue-pattern: ".*guidelines for Contributing.*"
    pr-pattern: ".*guidelines for Contributing.*"
    pr-close-message: |
      @${issue.user.login} your PR "${{ github.event.issue.title }}" was automatically closed because it did not follow the issue template
{% endraw %}```
