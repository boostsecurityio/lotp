---
title: MSBuild
tags:
- cli
- config-file
- input-file
- eval-sh
references:
- https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild
- https://learn.microsoft.com/en-us/visualstudio/msbuild/customize-by-directory
- https://learn.microsoft.com/en-us/visualstudio/msbuild/how-to-use-project-sdk
---

MSBuild is a platform for building C#/.NET applications. It comes together with Visual Studio, but can be installed separately.

The configuration is an XML file with `.csproj` or `.proj` extension.

It can be executed by running either `msbuild <file>` or `dotnet build <file>`.

Sample `build.proj` config:

```xml
<Project DefaultTargets="Build">
  <Target Name="Build">
    <Exec Command="whoami" /> <!-- Code goes here -->
  </Target>
</Project>
```

You can also inject into the MSBuild process without modifying an existing file. The original project must import `Microsoft.Common.props` or use an SDK-style project.

## `Directory.Build.props`

MSBuild searches upwards from the project directory for `Directory.Build.props` and imports it automatically. A target can attach to the build:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Build">
    <Exec Command="whoami" />
  </Target>
</Project>
```

## Restore hooks

An imported `Directory.Build.targets` can execute a command before restore, without compiling or running the application:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

```console
dotnet msbuild App.csproj -t:Restore
```

## NuGet-distributed MSBuild SDK

A selected MSBuild SDK package supplies `Sdk/Sdk.props` and `Sdk/Sdk.targets`. MSBuild resolves and imports these during project evaluation, including the first restore:

```xml
<Project Sdk="Microsoft.NET.Sdk;Example.Sdk/1.0.0">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
</Project>
```

Sample package file `Sdk/Sdk.targets`:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

SDK resolution must have access to the package through the configured feeds or cache.
