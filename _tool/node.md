---
layout: tool
title: node
tags: [cli, env-var, eval-js]
references:
- https://nodejs.org/api/cli.html#node_optionsoptions
files: []
---

## Living Off The Pipeline - node

The `node` runtime itself, independent of its package managers, can be abused as a powerful "Living Off The Pipeline" (LOTP) **Execution Gadget**. The vector is not a repository-local configuration file, but the `NODE_OPTIONS` environment variable.

### First-Order LOTP Gadget (Execution Gadget)

`node` is a **First-Order LOTP Gadget**. It does not initiate an attack on its own, but it can be triggered by a change made by a "Setup Gadget," leading to Remote Code Execution (RCE).

#### Malicious Primitive: Remote Code Execution (RCE)

The `NODE_OPTIONS` environment variable allows for passing command-line options to the `node` executable. One of these options is `--require` (or `-r`), which preloads a specified module before any other code is run.

An attacker can use a "Setup Gadget" to poison the `NODE_OPTIONS` variable. Any subsequent, seemingly benign `node` command in the same CI/CD job will then be forced to execute the attacker's malicious script at startup.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A malicious Node.js script (e.g., `pwn.js`).
    *   A file that a "Setup Gadget" will use to poison the environment (e.g., a malicious `.env` file).

2.  **Vulnerable Workflow:** The pipeline has two distinct steps.
    ```yaml
    - name: Load environment (Setup)
      run: source .env # This .env file is controlled by the attacker

    - name: Run application (Execution)
      run: node index.js
    ```

3.  **Execution:**
    *   **Setup:** The `source .env` command runs. The attacker's `.env` file contains the line `export NODE_OPTIONS="--require ./pwn.js"`, which poisons the environment for subsequent steps.
    *   **Execution:** The `node index.js` command runs. The `node` process starts, reads the poisoned `NODE_OPTIONS` variable, and immediately loads and executes the attacker's `pwn.js` script, achieving RCE before `index.js` is ever run.

This makes `node` a very dangerous execution gadget, as it can turn any standard Node.js execution in a pipeline into an RCE trigger.