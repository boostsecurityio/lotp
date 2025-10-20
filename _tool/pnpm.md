---
layout: tool
title: pnpm
parent: Living Off The Pipeline
nav_order: 10
---

## Living Off The Pipeline - pnpm

`pnpm` is a fast and disk-space-efficient package manager for Node.js. It is designed with a strong security-first mindset, notably by disabling the automatic execution of lifecycle scripts from dependencies by default. However, because this security feature is configurable via a file within the repository, `pnpm` can still be abused as a "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`pnpm` is a **First-Order LOTP Tool**. Its security settings can be disabled by an attacker-controlled configuration file, leading to Remote Code Execution (RCE) during a standard `pnpm install` command.

#### Malicious Primitive: Remote Code Execution (RCE)

By default, `pnpm` does not execute `preinstall`, `install`, or `postinstall` scripts for dependencies. However, this behavior can be overridden by settings in the `package.json` file or a `.npmrc` file.

An attacker can submit a pull request that both disables this security feature and adds a dependency with a malicious `postinstall` script. When the CI/CD pipeline runs `pnpm install`, it will read the attacker's configuration, disable its own protections, and execute the malicious script.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A modified `package.json` that disables the script execution security feature.
        ```json
        {
          "name": "a-legit-project",
          "dependencies": {
            "malicious-package": "1.0.0"
          },
          "pnpm": {
            "dangerouslyAllowAllBuilds": true
          }
        }
        ```
    *   The `malicious-package` would contain its own `package.json` with a `postinstall` script.

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to install dependencies.
    ```yaml
    - name: Install dependencies
      run: pnpm install
    ```

3.  **Execution:**
    *   The `pnpm install` command reads the attacker's `package.json`.
    *   It respects the `dangerouslyAllowAllBuilds: true` flag and disables its primary security feature.
    *   It proceeds to install `malicious-package` and executes its `postinstall` script.
    *   The attacker's payload runs, leading to RCE.

This attack is dangerous because it subverts a known security feature by manipulating the very file that controls it.

### References

*   [pnpm `dangerously-allow-all-builds` setting](https://pnpm.io/npmrc#dangerously-allow-all-builds)
