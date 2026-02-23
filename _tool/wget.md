---
title: wget
tags:
  - cli
  - config-file
  - eval-sh
references: 
  - https://linux.die.net/man/1/wget
  - https://github.com/mirror/wget
files: [.wgetrc]
---

`wget` is a GNU utility for non-interactive downloads of files from the web (with a few other supported protocols).

## Configuration file

The `wget` utility can be configured through the `.wgetrc` configuration file. As it stands, this file is located in the current user's home directory.

It's possible to specify the location of this configuration file through the `$WGETRC` and `$SYSTEM_WGETRC` environment variables. Additionally, the `$HOME` environment variable can be used to change the directory that contains the `.wgetrc` file (but the file still needs to be named this way).

The values of the `.wgetrc` map 1-to-1 with arguments passed to the `wget` command.

## Code execution

To support HTTP Basic authentication, `wget` can be configured to prompt the user for credentials through an arbitrary executable specified by the `--use-askpass` flag or the `use_askpass` configuration value.

#### .wgetrc
```ini
use_askpass=./pwn.sh
```

#### pwn.sh
```bash
#!/bin/bash
touch pwned
echo dummy # we print something to "fulfill" the askpass contract and avoid an error from wget
```