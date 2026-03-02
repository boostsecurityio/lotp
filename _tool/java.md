---
title: java
tags:
  - cli
  - env-var
references: 
  - https://www.ibm.com/docs/en/sdk-java-technology/8?topic=options-xxonoutofmemoryerror
files: []
---

`java` is used to execute Java programs.

## Environment variable poisoning

By default, `java` doesn't load any configuration files in the current directory. However, if we're able to poison a single environment variable, we can gain code execution during _most*_ `java`/`maven`/`gradle`/`...` invocation through the `$_JAVA_OPTIONS`, `$JAVA_TOOL_OPTIONS` or `$JDK_JAVA_OPTIONS` environment variables.

> \* This technique relies on causing an **OutOfMemoryError** in the Java process. Java is memory-hungry enough for this to not be a problem in most cases, but this might not be possible with a "hello world".

The previously mentioned environment variables can append arguments to the running JVM instance. As such, we can use the `-XX:OnOutOfMemoryError` flag combined with a strict memory limit such as `-Xmx2m` to invoke a command of our choice.

It's worth mentioning that different implementations of the JVM may have different minimum values for the maximum heap size (`-Xmx`) so there might be some tweaking to be done.

For instance, the assignment `_JAVA_OPTIONS='-XX:OnOutOfMemoryError="echo pwned" -Xmx2m'` would lead to `pwned` being printed in the vast majority of Java invocations.