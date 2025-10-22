---
layout: tool
title: yq
tags: [cli, input-file, file-read, data-exfiltration]
references:
- https://mikefarah.gitbook.io/yq/operators/load
- https://mikefarah.gitbook.io/yq/operators/env-variable-operators
files: [any]
---

## Living Off The Pipeline - yq

`yq` is a command-line processor for YAML and other structured data. Like its counterpart `jq`, it is a powerful language that, while sandboxed from the network and shell, can be abused as a "Living Off The Pipeline" (LOTP) gadget for data exfiltration and arbitrary file reads.

### First-Order LOTP Gadget

`yq` is a **First-Order LOTP Gadget**. It does not provide RCE, but its language features can be used to read sensitive files and environment variables and print them to the CI/CD logs.

#### Malicious Primitives

The `yq` language provides two key functions for this attack:
1.  **`load(file_path)`:** This function reads and parses a file from the specified path on the filesystem, providing an **Arbitrary File Read** primitive.
2.  **`env(VAR_NAME)`:** This function reads the value of an environment variable, providing a **Data Exfiltration** primitive when combined with log output.

An attacker can craft a `yq` expression that uses these functions and prints the result to standard output. In a CI/CD context, this output is captured in the pipeline logs.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified shell script that is used by the CI pipeline. The script is poisoned with a malicious `yq` command.
    ```bash
    # scripts/helper.sh

    # ... legitimate script commands ...

    # Malicious Payload 1: Read a secret file and print its contents
    echo "Reading file:"
    yq 'load("/etc/passwd")'

    # Malicious Payload 2: Read a secret env var and print it
    echo "Reading secret:"
    yq 'env("API_KEY")'

    # ... more legitimate script commands ...
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to execute the helper script.
    ```yaml
    - name: Run helper script
      run: bash ./scripts/helper.sh
      env:
        API_KEY: ${{ secrets.API_KEY }}
    ```

3.  **Execution:**
    *   The `bash ./scripts/helper.sh` command is executed.
    *   The malicious `yq` commands run. The first reads `/etc/passwd` and prints it to stdout. The second reads the `API_KEY` environment variable and prints it to stdout.
    *   The CI/CD platform captures this output in its logs. The attacker can then review the logs to retrieve the stolen file contents and secret.

This attack is dangerous because the CI/CD command is benign. The vulnerability lies in the powerful, non-obvious features of the `yq` language being executed by a trusted script.