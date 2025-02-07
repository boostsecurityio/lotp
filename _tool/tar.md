---
title: tar
tags:
- cli
- input-file
- env-var
references: https://man.freebsd.org/cgi/man.cgi?tar(1)#SECURITY
files: ['*.tar', '*.tar.gz', '*.tar.xz', '*.tar.tz', '*.tar.bz2', '*.tar.z']
---

`tar` is a widely used archiver.

## Zip Slip

If `tar` uses `-P` or `--absolute-names`, it is vulnerable to [Zip Slip](https://security.snyk.io/research/zip-slip-vulnerability), where a malicious archive can overwrite files in any parent directories. It can be used to:
  - Poison the source code
  - Replace an executable or a config file which can lead to RCE
To create a malicious archive:
```sh
tar cPf zipslip.tar ../../../../../../bin/sh
```

To poison:
```
tar xPf zipslip.tar
```

## Environnement variable

`tar` prepend **TAR_OPTIONS** env variable to every call. See [Using tar Options](https://www.gnu.org/software/tar/manual/html_section/using-tar-options.html). If the environment variable of a CI can be poison, **TAR_OPTIONS** can lead to RCE via:
```sh
export TAR_OPTIONS='--checkpoint=1 --checkpoint-action=exec=sh'
export TAR_OPTIONS='--to-command sh'
tar xf test.tar
```
