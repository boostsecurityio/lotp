---
title: PHPStan
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://phpstan.org/config-reference#bootstrap
- https://phpstan.org/config-reference#config-file
files: [phpstan.neon,phpstan.neon.dist,phpstan.dist.neon]
---

`phpstan` scans your whole codebase and looks for both obvious & tricky bugs. 
It is controlled via `phpstan.neon`,`phpstan.dist.neon` or `phpstan.neon.dist` in the current directory. RCE is available through Bootstrap.

```yaml
parameters:
	level: 1
	bootstrapFiles:
		- pwn.php
```
