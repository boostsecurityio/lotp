---
title: Ant
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://ant.apache.org/manual/Tasks/exec.html
files: [build.xml,ant.properties]
---

Ant is a Java-based build tool used to compile, assemble, test, and run Java applications. Ant uses XML files for its configuration, primarily named `build.xml`. These files define a set of tasks to be executed.

Ant allows the execution of arbitrary shell commands via the `<exec>` task within its `build.xml` or any imported XML files.

Ant often refers to a properties file (`ant.properties`) to load key-value pairs which are using in the `build.xml`, while whatever is put in that file cannot directly be executed, if it is consumed inside of the `build.xml` in a way that could lead to RCE, this mean be yet another injection point.
## `build.xml`

```xml
<project name="POC" default="run">
    <property file="ant.properties"/>
    <target name="run">
        <exec executable="sh" inputstring="echo 'Hello from Ant'"/>
        <exec executable="sh" inputstring="${command.to.execute}"/>
    </target>
</project>
```

## `ant.properties`

```text
command.to.execute=id
```
