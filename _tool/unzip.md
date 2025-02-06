---
title: unzip
tags:
- cli
references: 
files: ['*.zip']
---

unzip is a widly used archiver. 

## Zip Slip

If unzip is unsed with `-:` is vulnerable to [Zip Slip](https://security.snyk.io/research/zip-slip-vulnerability), where a malicious archive can overwrite files in parent directory. It can be used to:
  - Poison the source code
  - Replace an executable or a config file which can lead to RCE
To create a malicious archive:
```sh
zip zipslip.zip ../../../../../../bin/sh
```
