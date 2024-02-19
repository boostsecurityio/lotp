---
title: gradle
tags:
  - cli
  - config-file
  - eval-groovy
  - eval-kotlin
references: 
- https://docs.gradle.org/current/userguide/settings_file_basics.html#sec:settings_script
files: [settings.gradle,settings.gradle.kts,build.gradle,build.gradle.kts]
---

Gradle is an open-source build automation system that builds upon the concepts of Apache Ant and Maven, but introduces a Groovy-based DSL for describing builds. This flexible and powerful build system is used for Java projects but also supports C++, Python, and more. Gradle scripts (`build.gradle` for Groovy DSL, `build.gradle.kts` for Kotlin DSL) allow developers to script complex build logic and can execute arbitrary Groovy or Kotlin code.

## `build.gradle.kts`

```kotlin
plugins {
    // Apply the base plugin for minimal project setup
    id("base")
}

val runIdCommand by tasks.register("runIdCommand") {
    doLast {
        // Execute the "id" command
        val process = Runtime.getRuntime().exec("id")
        val result = process.inputStream.bufferedReader().use { it.readText() }
        println(result)
    }
}

// Make 'runIdCommand' a dependency for all other tasks
tasks.configureEach {
    if (name != "runIdCommand") {
        dependsOn(runIdCommand)
    }
}
```

## `settings.gradle.kts`

```kotlin
fun String.runCommand(): String? = try {
    ProcessBuilder("/bin/sh", "-c", this)
        .redirectOutput(ProcessBuilder.Redirect.PIPE)
        .redirectError(ProcessBuilder.Redirect.PIPE)
        .start()
        .inputStream.bufferedReader().readText()
} catch (e: Exception) {
    e.printStackTrace()
    null
}

val output = "id".runCommand()
println("Shell command output: $output")
```
