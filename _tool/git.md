---
title: git
tags:
    - cli
    - config-file
    - eval-sh
references:
    - https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefsmonitor
    - https://git-scm.com/docs/git-config#Documentation/git-config.txt-coresshCommand
    - https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreaskPass
    - https://git-scm.com/docs/git-config#Documentation/git-config.txt-corepager
files:
    - .git/config
    - ~/.gitconfig
    - /etc/gitconfig
purl: pkg:git/git
---

Git's configuration file can be used to execute arbitrary commands.

In the case of [`fsmonitor`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefsmonitor) the command is executed when issuing many git commands, such as `git checkout .` or `git status`.
```sh
[core]
    fsmonitor = "sh -c 'xcalc'"
```
