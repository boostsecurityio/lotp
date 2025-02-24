---
title: maven
tags:
- cli
- eval-sh
- env-var
- config-file
references:
- https://central.sonatype.com/artifact/org.codehaus.mojo/exec-maven-plugin
- https://maven.apache.org/configure.html#maven_opts-environment-variable
files: [pom.xml]
---

## Config file

In `pom.xml`, plugins can be added.  The plugin `org.codehaus.mojo/exec-maven-plugin` can be used to run shell commands. For example, running the `env` command after the `clean` phase:

```xml
<build>
  <plugins>
    [...]
    <plugin>
      <groupId>org.codehaus.mojo</groupId>
      <artifactId>exec-maven-plugin</artifactId>
      <version>3.1.1</version>
      <executions>
        <execution>
          <id>run-after-clean</id>
          <phase>clean</phase>
          <goals>
            <goal>exec</goal>
          </goals>
          <configuration>
            <executable>sh</executable>
            <arguments>
              <argument>-xc</argument>
              <argument>env</argument>
            </arguments>
          </configuration>
        </execution>
      </executions>
    </plugin>
    [...]
  </plugins>
</build>
```

## Environment poisoning

If the attacker has control over the environment variable, since version 3.9,  **MAVEN_ARGS** can be used to inject a plugin and gain RCE. In Gitlab, the previous version of Mavan can be used with **MAVEN_CLI_OPTS**, see this [example](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Maven.gitlab-ci.yml).

```sh
export MAVEN_ARGS="org.codehaus.mojo:exec-maven-plugin:3.2.0:exec -Dexec.executable=/bin/sh"
```
