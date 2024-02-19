---
title: maven
tags:
- cli
- eval-sh
references:
- https://central.sonatype.com/artifact/org.codehaus.mojo/exec-maven-plugin
---

In `pom.xml`, plugins can be added. The plugin `org.codehaus.mojo/exec-maven-plugin` can be used to run shell commands. For example, running the `env` command after the `clean` phase:

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
