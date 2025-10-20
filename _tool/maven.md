---
layout: tool
title: mvn
parent: Living Off The Pipeline
nav_order: 9
---

## Living Off The Pipeline - mvn (Maven)

Apache Maven is a build automation tool for Java projects. Its build process is driven by a `pom.xml` file and can be influenced by environment variables, both of which can be manipulated by an attacker to execute arbitrary code.

### Vector 1: `pom.xml` Plugin Execution (First-Order LOTP Tool)

Maven's primary LOTP vector is its plugin architecture, configured via the `pom.xml` file. This makes `mvn` a **First-Order LOTP Tool**.

#### Malicious Primitive: Remote Code Execution (RCE)

The `pom.xml` file allows a developer to define plugins that execute at specific phases of the build lifecycle. An attacker can abuse this by adding a malicious plugin configuration to the `pom.xml` in their pull request. When a standard `mvn` command (like `mvn install`) is run, Maven will execute the attacker's plugin, leading to RCE. A common choice for this is the `exec-maven-plugin`.

*   **Attack Chain:**
    1.  **Attacker's PR:** An attacker submits a pull request with a modified `pom.xml` containing a malicious plugin execution bound to an early phase like `validate`.
    2.  **Vulnerable Workflow:** The pipeline runs a standard command like `mvn install`.
    3.  **Execution:** Maven parses the `pom.xml`, finds the malicious plugin, and executes its payload.

### Vector 2: Environment Variable Poisoning (Execution Gadget)

Maven's startup script reads environment variables like `MAVEN_ARGS` to allow for command-line arguments to be set globally. This makes `mvn` a powerful **Execution Gadget** in a Second-Order attack.

#### Malicious Primitive: Remote Code Execution (RCE)

An attacker can use a "Setup Gadget" to write a malicious value to the `MAVEN_ARGS` environment variable. Any subsequent `mvn` command in the same job will then execute the attacker's payload.

*   **Attack Chain:**
    1.  **Setup Gadget:** A tool in the pipeline is exploited to write to the environment file (e.g., `echo "MAVEN_ARGS=...malicious plugin..." >> $GITHUB_ENV`).
    2.  **Execution Gadget (`mvn`):** A later step in the pipeline runs a standard `mvn install` command. The Maven process starts, reads the poisoned `MAVEN_ARGS` variable from the environment, and executes the attacker's malicious command.

### References

*   [Maven Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)
*   [Exec Maven Plugin](https://www.mojohaus.org/exec-maven-plugin/)
*   [Configuring Maven (`MAVEN_OPTS`)](https://maven.apache.org/configure.html)