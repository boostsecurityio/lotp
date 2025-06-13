---
title: just
tags:
- cli
- config-file
- eval-sh
references:
- https://just.systems/man/en/
- https://just.systems/man/en/settings.html
files:
- justfile
---

`just` is a command runner. It uses a `justfile` to define and run project-specific commands, often involving shell script execution. `@` can be used at the start of line to supress the output to stdout. It is similar to [make](https://boostsecurityio.github.io/lotp/tool/make).

```make
default:
	id
```
