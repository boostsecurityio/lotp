---
title: MSBuild
tags:
- cli
- config-file
- input-file
- eval-sh
references:
- https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild
---

MSBuild is a platform for building C#/.NET applications. It comes together with Visual Studio, but can be installed separately. 

The configuration is a XML file with `.csproj` or `.proj` extension.

It can be executed by running either `msbuild <file>` or `dotnet build <file>`.

Sample `build.proj` config:
```xml
<Project DefaultTargets="Build">
  <Target Name="Build">
    <Exec Command="whoami" /> <!-- Code goes here -->
  </Target>
</Project>
```

You can also inject into MSBuild process without modifying any existing file and creating a new one insted.
For this to be possible, the original project has to either import `Microsoft.Common.props` or it needs to be an [SDK style project](https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild?view=vs-2022#project-file).

MSBuild will look for a `Directory.Build.Targets` in a project directory and all parent directories, and imports it automatically.

When imported, you can inject into the process using `BeforeTargets` keyword.

```xml
<Project>
  <Target Name="malicious" BeforeTargets="Build">
    <Exec Command="echo 'injected!'" />  <!-- Code goes here -->
  </Target>
</Project>
```
