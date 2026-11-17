---
title: jfrog
tags:
  - cli
  - config-file
  - input-file
  - eval-sh
files: ["*.csproj", Directory.Build.targets]
references:
  - https://github.com/jfrog/jfrog-cli/blob/v2.131.0/buildtools/cli.go#L1248-L1299
  - https://github.com/jfrog/jfrog-cli-artifactory/blob/30c80a7deec47e31611c565f2a5a01a570e31ee1/artifactory/commands/nuget/command.go#L117-L255
---

JFrog CLI's .NET wrapper delegates restore to `dotnet`.

## `Directory.Build.targets`

An attacker controlling the project or its imports can execute a command before restore:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```sh
jf dotnet restore App.csproj
```
