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

## Via `$GITHUB_ENV` environement variables poisoning

By poisoning environment variables via the file pointed to by `$GITHUB_ENV`, subsequent Bash executions could execute code such as in a different step.
  - **BASH_ENV**: This variable will be executed before entering the next shell. `echo BASH_ENV='$(id 1>&2)' >> $GITHUB_ENV`

This means there is pre-requisite of a some kind of RCE or at very least arbitrary file write to the `$GITHUB_ENV` file.

## Configuration file

If the `.bashrc`, `.bash_profile`, or `.initrc` is poison with an environment variable definition (`export BASH_ENV=...`), the next bash execution will be poison.

Note: GitHub Actions uses `bash --noprofile --norc -e -o pipefail {0}` which doesn't load configuration files.
