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
  - **BASH_ENV**: This variable will be executed before entering the next shell.

For instance:
- `echo BASH_ENV='$(id 1>&2)' >> $GITHUB_ENV`
- `echo BASH_ENV=some-script.sh >> $GITHUB_ENV`

This means there is pre-requisite of a some kind of RCE or at very least arbitrary file write to the `$GITHUB_ENV` file.

## Configuration file

Alternatively if the `.bashrc`, `.bash_profile`, or `.initrc` can be poisonned (on some CI environments other than GitHub Actions, maybe), that will affect subsequent Bash execution.

⚠️ Important Note ⚠️: GitHub Actions runners execute the `run:` statements using `bash --noprofile --norc -e -o pipefail {0}` which DOES NOT load those configuration files.
