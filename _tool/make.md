---
title: make
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://www.gnu.org/software/make/manual/make.html#Introduction
files: [Makefile]
---

The `make` utility automatically determines which pieces of a large program need to be recompiled, and issues commands to recompile them. It can be configured using a Makefile which can execute bash directly.

```Makefile
pwn:
	id
```
