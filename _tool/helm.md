---
layout: tool
title: helm
tags: [cli, config-file, file-write]
references:
- https://helm.sh/docs/helm/helm_dependency/
- https://nvd.nist.gov/vuln/detail/CVE-2022-24348
files: [Chart.yaml]
---

## Living Off The Pipeline - helm

`Helm` is the package manager for Kubernetes. While it has security controls to prevent templates from accessing the local filesystem, its dependency management features can be abused through symbolic link attacks, making it a powerful "Living Off The Pipeline" (LOTP) "Setup Gadget".

### First-Order LOTP Gadget

`Helm` is a **First-Order LOTP Gadget**. It does not provide direct RCE, but it can be tricked into writing arbitrary files to the filesystem, which can then be used to set up a Second-Order RCE attack.

#### Malicious Primitive: Arbitrary File Write

The attack vector is the `helm dependency update` command. This command is used to download and unpack chart dependencies into the `charts/` directory and to update the `Chart.lock` file.

An attacker can replace a file or directory that Helm writes to (e.g., the `charts/` directory) with a symbolic link pointing to a sensitive location on the runner's filesystem, such as `~/.bashrc`.

When `helm dependency update` runs, it will follow this symlink and write the contents of a dependency chart to the sensitive location. If the attacker crafts the dependency chart to contain a malicious payload, they can achieve an arbitrary file write, poisoning a file that will be executed later.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request containing a malicious Helm chart. In this chart, the `charts` directory has been replaced with a symlink.
    ```bash
    # Attacker creates a symlink in their chart
    ln -s ~/.bashrc charts
    ```
    The attacker also modifies the `Chart.yaml` to include a dependency on a malicious chart they control. This malicious chart contains a file with a payload, e.g., `export RCE="pwned"`.

2.  **Vulnerable Workflow:** The pipeline contains a standard command to prepare Helm dependencies before linting or deploying.
    ```yaml
    - name: Update chart dependencies
      run: helm dependency update ./my-malicious-chart
    ```

3.  **Execution (Setup):**
    *   The `helm dependency update` command is executed.
    *   It attempts to download the attacker's malicious dependency and unpack it into the `charts` directory.
    *   It follows the symlink and instead writes the malicious dependency's content (including the `export RCE="pwned"` payload) into the runner's `~/.bashrc` file.

4.  **Execution (RCE):**
    *   A later step in the CI/CD job, or any subsequent job on the same runner, starts a new bash shell.
    *   The shell sources the `~/.bashrc` file, executing the attacker's payload.