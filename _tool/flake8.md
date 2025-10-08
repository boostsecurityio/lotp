---
title: flake8
tags:
- cli
- config-file
- eval-py
references:
- https://flake8.pycqa.org/en/latest/user/configuration.html
files: [.flake8, tox.ini, setup.cfg]
---

`flake8` is a popular Python linter, a tool to check Python code against coding standards.

## Configuration Files `.flake8`, `setup.cfg`, `tox.ini`

When running, `flake8` automatically discovers and reads its configuration from one of three files if present in the project root: `.flake8`, `setup.cfg`, or `tox.ini`.

These configuration files can instruct `flake8` to load **local plugins**. A local plugin is a Python script located within the repository itself. This feature can be abused to achieve arbitrary python code execution.

An attacker can submit a pull request containing a malicious configuration file (e.g. `.flake8`) and a Python script. When a CI/CD workflow checks out the code and runs `flake8`, it will:
1.  Read the malicious `.flake8` file.
2.  Load the local plugin specified in the file (`pwn.py`).
3.  Execute the Python code within the plugin.

This provides a direct path to code execution on the runner. The same attack payload works for all three configuration file types.

```toml
# `.flake8` file

[flake8]
...

[flake8:local-plugins]
extension =
    malicious_plugin = script:main
```
In this example, the attacker defines a malicious `main` function in `script.py` that gets executes when `flake8 ...` is called. 