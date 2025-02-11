---
title: Bash
tags:
  - cli
  - config-file
  - env-var
references: 
- https://www.gnu.org/software/bash/manual/bash.html#Bash-Variables
files: [.bashrc,.initrc,.bash_profile]
---

`bash` is used to execute a shell command.

## Environnement variable poisoning

By poisoning the environment variable, future bash execution could execute code in a different step.
  - **BASH_ENV**: This variable will be executed before entering the next shell. `BASH_ENV='$(id 1>&2)'`

## Configuration file

If the `.bashrc`, `.bash_profile`, or `.initrc` is poison with an environment variable definition (`export BASH_ENV=...`), the next bash execution will be poison.

Note: GitHub Actions uses `bash --noprofile --norc -e -o pipefail {0}` which doesn't load configuration files.
