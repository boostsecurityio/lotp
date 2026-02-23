---
title: gauge
tags:
  - cli
  - config-file
  - eval-sh
references: 
  - https://docs.gauge.org/configuration
  - https://docs.gauge.org/overview.html?language=javascript#what-is-an-implementation
  - https://github.com/getgauge/gauge
files: [manifest.json, env/*/*.properties]
---

`gauge` is a light weight cross-platform test automation tool.

## Configuration file

`gauge` is configured through a main manifest file named `manifest.json` which specifies the project's language and the plugins that are in use.

Additionally, any `.properties` files located under `env/*/` are loaded as environment variables to configure `gauge`, its language-specific test runners and plugins.

## Code execution

The most straight-forward way to achieve code execution during test execution is to modify the implementation of the test steps. The specific details vary from language to language, in the case of Python, the `step_impl` directory will be loaded as a module.

If the result of the workflow steps isn't important, we can set the language of our `gauge` project to `Python` and configure the `GAUGE_PYTHON_COMMAND` to point towards a controlled script.

#### manifest.json
```json
{
  "Language": "python",
  "Plugins": [
    "html-report"
  ]
}
```

#### env/default/python.properties
```ini
GAUGE_PYTHON_COMMAND=${PWD}/pwn.sh
```

#### pwn.sh
```bash
#!/bin/bash
touch pwned
python "$@" # optionally to preserve regular behavior
```