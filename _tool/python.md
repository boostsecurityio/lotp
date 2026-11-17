---
title: python
tags:
  - cli
  - input-file
  - env-var
references:
  - https://docs.python.org/3/using/cmdline.html
  - https://docs.python.org/3/library/sys_path_init.html
  - https://docs.python.org/3/reference/import.html
files: [script.py, pip.py, struct.py]
---

`python` can execute an untrusted script directly or load untrusted code during a trusted command.

## Direct execution

If a pipeline runs an attacker-controlled script, its code runs directly:

```sh
python script.py
```

`python -I script.py` still runs that script; isolation only changes how Python finds imports and handles environment settings.

## Module shadowing

### Shadow the invoked module

With `-m`, `-c`, or standard input, Python searches the current directory first for imports. A checkout containing `pip.py` can intercept an existing command:

```sh
python -m pip --version
```

```python
# pip.py in the working directory
print("LOTP: local pip.py executed")
```

This replaces pip rather than continuing the install. The same applies to other `python -m NAME` commands if the checkout contains `NAME.py`.

### Shadow a transitive import

An import *inside* trusted code can also be shadowed. For example, `base64` imports `struct`:

```sh
python -c 'import base64; print(base64.b64decode("aGVsbG8=").decode())'
```

```python
# struct.py in the working directory
from _struct import *
from _struct import _clearcache
print("LOTP: local struct.py executed")
```

Forwarding `_struct` lets this command finish. The result depends on the import chain and whether a module has already been loaded; not every Python command imports `struct`.

`python /trusted-tools/process.py` instead puts the script's directory first, not an unrelated working directory. An installed `pip` launcher also does not automatically search the working directory in the same way as `python -m pip`. Other paths or local package installation can still introduce untrusted code.

## Environment-variable poisoning

An attacker who can poison the process environment can run code without changing the script. `PYTHONWARNINGS` imports `antigravity` while parsing a warning category. `antigravity` opens an XKCD URL via `webbrowser`, which uses `BROWSER` to choose the program. If `BROWSER` selects Bash, Bash reads the file named by `BASH_ENV` on startup:

```sh
printf 'echo "LOTP: browser shell ran"\n' > browser.sh
PYTHONWARNINGS='::antigravity.::' BROWSER=/bin/bash BASH_ENV="$PWD/browser.sh" python -c 'pass'
```

This prints `LOTP: browser shell ran` before Bash tries to open the URL as a script. Python may also report an invalid warning category *after* the import. The sandbox uses the same chain to verify access to `FLAG`; `antigravity` is not imported by default.

Use `python -I` where compatible to ignore `PYTHON*` variables and exclude the automatic unsafe import path. `-P` (Python 3.11+) only prevents that path; `-E` only ignores `PYTHON*` variables. Neither alone covers both routes.

[Sandbox reproduction](https://github.com/boost-rnd/lotp-sandbox/tree/main/python)
