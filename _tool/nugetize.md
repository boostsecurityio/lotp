---
title: NuGetizer CLI
tags:
  - cli
  - config-file
  - input-file
  - eval-sh
files: ["*.csproj", Directory.Build.targets]
references:
  - https://github.com/devlooped/nugetizer
  - https://github.com/devlooped/nugetizer/blob/f0ba72a674a0f5e5321621e19fadfee10f927b61/src/dotnet-nugetize/Program.cs
---

`nugetize`, distributed as `dotnet-nugetize`, inspects package contents by invoking MSBuild targets.

## `Directory.Build.targets`

An attacker controlling the inspected project or an imported build file can attach a command to `GetPackageContents`:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="GetPackageContents">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```console
nugetize App.csproj
```

The inspector's design-time and compiler-skipping settings do not disable project tasks. Execution can precede an inspection failure; a nonzero exit does not mean the command was safe.
