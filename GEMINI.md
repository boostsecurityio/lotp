A tool is considered a "Living Off The Pipeline" (LOTP) gadget when it can be abused by an attacker to achieve a malicious outcome within a CI/CD pipeline. This typically occurs in a Poisoned Pipeline Execution (PPE) scenario, where an attacker submits a pull request containing a malicious file that a pipeline tool consumes.

There are two main concepts in this framework:

### First-Order LOTP (Direct Primitive Gadget)

This is a tool that, in a single step, produces a malicious primitive by processing an attacker-controlled file. These gadgets are the fundamental building blocks of pipeline attacks. The malicious primitive is not always full Remote Code Execution (RCE); lesser, but still powerful, primitives are more common.

An attacker-controlled file can be one of two types:

1.  **Configuration File:** A file the tool implicitly loads from the workspace. An attacker modifies this file to alter the tool's behavior.
2.  **Data Input File:** A file that is explicitly passed to the tool as its primary input.

The outcome of a First-Order LOTP is a **malicious primitive**. Common primitives include:
*   **Remote Code Execution (RCE):** The most powerful primitive, giving the attacker full control.
    *   *Examples:* `make` executing a command from a `Makefile`, `npm` running a malicious `postinstall` script.
*   **Arbitrary File Write:** The ability to write or overwrite files on the runner's filesystem. This is a powerful "Setup" primitive.
    *   *Examples:* An XSLT processor using `exsl:document` with a `file:///` URI, a static site generator with a configurable output directory that allows path traversal.
*   **Arbitrary File Read:** The ability to read files from the runner's filesystem. This can be used for data exfiltration.
    *   *Examples:* An XML processor that resolves external entities (`XXE`), a template engine that can include local files.
*   **Arbitrary Network Access:** The ability to make network requests to arbitrary endpoints. This is often used for data exfiltration.
    *   *Examples:* A tool with a templating feature that can perform DNS lookups or HTTP requests (like `trivy`), an XSLT processor using the `document()` function to fetch a remote DTD or stylesheet.
*   **Environment Variable Manipulation:** The ability to set or modify environment variables for subsequent steps in the pipeline. This is a classic "Setup" primitive.

### Second-Order LOTP (Chained Gadget Attack)

A Second-Order LOTP is not a type of gadget, but rather an **attack chain** that involves at least two gadgets:

1.  **The "Setup" Gadget:** A First-Order LOTP that provides a non-RCE primitive, such as writing a file, reading a secret, or setting an environment variable.
2.  **The "Execution" Gadget:** A subsequent tool in the pipeline that is triggered by the change made by the setup gadget, leading to full RCE.

A prime example involves `bash` in GitHub Actions. A "setup" gadget (any First-Order LOTP with a file write primitive) could write `BASH_ENV=./attacker-script.sh` to the file at `$GITHUB_ENV`. The "execution" gadget would be `bash` itself in a later `run` step, which would then execute the script because the `BASH_ENV` variable causes `bash` to source the specified script upon startup. For more details on this mechanism, see: [`_tool/bash.md`](_tool/bash.md).

It is crucial to understand that while many potential "setup" gadgets exist, they only become exploitable vulnerabilities if a corresponding "execution" gadget exists later in the *same pipeline workflow* to complete the chain.
