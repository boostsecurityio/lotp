---
layout: tool
title: ./gradlew
parent: Living Off The Pipeline
nav_order: 5
---

## Living Off The Pipeline - ./gradlew (Gradle Wrapper)

The Gradle Wrapper (`gradlew`) is a standard utility in Java projects that ensures a consistent Gradle version is used for the build. It includes scripts and a JAR file that are committed directly to the repository, creating a powerful "Living Off The Pipeline" (LOTP) vector.

### First-Order LOTP Tool

The Gradle Wrapper is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) because the command to run it (`./gradlew`) executes a binary file that is controlled by the attacker.

#### Malicious Primitive: Remote Code Execution (RCE)

The core of the Gradle Wrapper is the `gradle/wrapper/gradle-wrapper.jar` file. This is an executable JAR that contains the logic to download and run the Gradle build tool. Since this JAR is checked into the repository, an attacker can replace it with a malicious, compiled Java application.

When a CI/CD pipeline executes a standard build command, it runs the attacker's malicious JAR file instead of the legitimate one.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request where they have replaced the legitimate `gradle/wrapper/gradle-wrapper.jar` with their own malicious version.

2.  **Vulnerable Workflow:** The pipeline contains a completely standard and seemingly safe command to build the project.
    ```yaml
    - name: Build Java project
      run: ./gradlew build
    ```

3.  **Execution:**
    *   The `./gradlew build` command is executed.
    *   The `gradlew` shell script invokes the Java Virtual Machine (JVM) to run the `gradle-wrapper.jar` file.
    *   The JVM executes the attacker's malicious JAR, leading to RCE on the CI runner.

This attack is particularly insidious because it is very difficult for a human reviewer to detect a malicious change in a compiled binary file like a `.jar` during a code review.

### References

*   [Gradle Wrapper Documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
*   [Validating the Gradle Wrapper JAR](https://docs.gradle.org/current/userguide/gradle_wrapper.html#sec:wrapper_checksum_validation)
