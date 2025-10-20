---
layout: tool
title: jq
parent: Living Off The Pipeline
nav_order: 16
---

## Living Off The Pipeline - jq

`jq` is a powerful command-line JSON processor. While it is intentionally sandboxed from the filesystem and network, its ability to read environment variables makes it a subtle but effective "Living Off The Pipeline" (LOTP) gadget for data exfiltration.

`jq` does not have a traditional configuration file that it loads automatically. The LOTP vector is the `.jq` script file itself, which an attacker can modify in a pull request.

### First-Order LOTP Gadget

`jq` is a **First-Order LOTP Gadget**. It does not provide RCE or direct network access, but it can be used to exfiltrate secrets by printing them to the CI/CD logs.

#### Malicious Primitive: Data Exfiltration via Log Output

The `jq` language provides two key features for this attack:
1.  The `env` object, which allows `jq` to read the values of environment variables.
2.  The ability to print any string to standard output or standard error (e.g., via the `debug` function).

An attacker can combine these to craft a `.jq` script that reads a secret from an environment variable and prints it. In a CI/CD context, this output is captured in the pipeline logs, which are often accessible to the attacker (e.g., the author of the pull request).

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified `.jq` script that is used for a legitimate purpose like validation. The script is poisoned with a data exfiltration payload.
    ```jq
    # scripts/validate_user.jq

    # Malicious Payload:
    # This reads the GITHUB_TOKEN and prints it to stderr.
    "SECRET_FOUND: \(env.GITHUB_TOKEN)" | debug

    # Legitimate validation logic can follow, so the script appears to work.
    .user.role == "admin"
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to use the `jq` script for validation.
    ```yaml
    - name: Validate user data
      run: jq -f scripts/validate_user.jq user.json
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ```

3.  **Execution:**
    *   The `jq -f ...` command is executed.
    *   `jq` runs the attacker's script. The `debug` function is called, which builds the string containing the value of the `GITHUB_TOKEN` environment variable.
    *   The string `SECRET_FOUND: ghs_...` is printed to `stderr`.
    *   The CI/CD platform captures this output in its logs. The attacker can then review the logs to retrieve the stolen token.

This attack is dangerous because the CI/CD command is benign and the tool is being used for its intended purpose. The vulnerability lies in combining two non-obvious features of the `jq` language to move a secret from a secure context to an insecure one.

### References

*   [jq Manual: `debug` function](https://stedolan.github.io/jq/manual/#debug)
*   [jq Manual: `env` object](https://stedolan.github.io/jq/manual/#env)
