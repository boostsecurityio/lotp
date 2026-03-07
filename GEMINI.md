A tool is considered a "Living Off The Pipeline" (LOTP) gadget when it can be abused by an attacker to achieve a malicious outcome within a CI/CD pipeline. This typically occurs in a Poisoned Pipeline Execution (PPE) scenario, where an attacker submits a pull request containing a malicious file that a pipeline tool consumes.

There are two main concepts in this framework:

### First-Order LOTP (Direct Primitive)

This is a tool or utility that, in a single step, produces a malicious primitive by processing an attacker-controlled file. These are the fundamental building blocks of pipeline attacks. To better classify the risk, we distinguish between "Tools" and "Gadgets":

*   A **First-Order LOTP Tool** provides direct **Remote Code Execution (RCE)**. These are the most critical vulnerabilities, as they give an attacker immediate control over the pipeline runner.
    *   *Examples:* `make` executing a command from a `Makefile`, `npm` running a malicious `postinstall` script in `package.json`.
*   A **First-Order LOTP Gadget** provides a lesser, non-RCE primitive. While not immediately granting RCE, these primitives are powerful building blocks for data exfiltration or for setting up a Second-Order attack.
    *   *Examples:* a tool with a templating feature allowing arbitrary network access for data exfiltration, an XSLT processor writing a file to a known location.

An attacker-controlled file can be one of two types:

1.  **Configuration File:** A file the tool implicitly loads from a location an attacker can control (e.g., the current working directory, the repository root). An attacker modifies this file to alter the tool's behavior. This is distinct from configuration files loaded from secure, trusted locations (e.g., a user's home directory), which do not constitute a LOTP vector.
2.  **Data Input File:** A file that is explicitly passed to the tool as its primary input.

The outcome of a First-Order LOTP is a **malicious primitive**. Common primitives include:
*   **Remote Code Execution (RCE):** The most powerful primitive, giving the attacker full control.
    *   *Examples:* `make` executing a command from a `Makefile`, `npm` running a malicious `postinstall` script in `package.json`.
*   **Arbitrary File Write:** The ability to write or overwrite files on the runner's filesystem. This is a powerful "Setup" primitive.
    *   *Examples:* An XSLT processor using a function with a `file:///` URI, a static site generator with a configurable output directory that allows path traversal.
*   **Arbitrary File Read:** The ability to read files from the runner's filesystem. This can be used for data exfiltration.
    *   *Examples:* An XML processor that resolves external entities (`XXE`), a template engine that can include local files.
*   **Arbitrary Network Access:** The ability to make network requests to arbitrary endpoints. This is often used for data exfiltration.
    *   *Examples:* A tool with a templating feature that can perform DNS lookups or HTTP requests, an XSLT processor using the `document()` function to fetch a remote DTD or stylesheet.
*   **Environment Variable Manipulation:** The ability to set or modify environment variables for subsequent steps in the pipeline. This is a classic "Setup" primitive.

It is critical to not only identify a primitive but also to verify its usefulness. A primitive is only valuable to an attacker if the data it exposes can be exfiltrated or acted upon. For example, an **Arbitrary File Read** is a **"dud primitive"** if the tool provides no mechanism to either print the file's contents to the CI/CD logs or send them over the network. An attacker can read the file, but they cannot see the contents. Similarly, an **Arbitrary File Write** is a dud if the attacker cannot control the file's contents or if the write is confined to a subdirectory within the attacker's own checkout. For a "Setup Gadget" to be effective, its file write primitive must allow writing to a location *outside* the checkout directory, thereby influencing a separate, trusted process (e.g., by overwriting a file like `$GITHUB_ENV` or dropping a malicious configuration file in a predictable system path). Therefore, a complete LOTP gadget must include both the primitive itself and a channel for output or exfiltration.

A critical aspect of this analysis is to consider the tool's security controls, such as sandboxing. A tool may appear safe because its dangerous features (e.g., filesystem or network access) are restricted by a default security policy. However, if this policy is defined in a configuration file that resides within the repository, it is under the attacker's control. In a PPE scenario, an attacker can submit a pull request that modifies this configuration to weaken or disable the sandbox, thereby unlocking the tool's full potential as a LOTP gadget. Therefore, the analysis must not only identify sandboxing features but also verify whether their configuration is secure from attacker influence.

### Second-Order LOTP (Chained Gadget Attack)

A Second-Order LOTP is not a type of gadget, but rather an **attack chain** that involves at least two gadgets:

1.  **The "Setup" Gadget:** A First-Order LOTP that provides a non-RCE primitive, such as writing a file, reading a secret, or setting an environment variable.
2.  **The "Execution" Gadget:** A subsequent tool in the pipeline that is triggered by the change made by the setup gadget, leading to full RCE.

A prime example involves `bash` in GitHub Actions. A "setup" gadget (any First-Order LOTP with a file write primitive) could write `BASH_ENV=./attacker-script.sh` to the file at `$GITHUB_ENV`. The "execution" gadget would be `bash` itself in a later `run` step, which would then execute the script because the `BASH_ENV` variable causes `bash` to source the specified script upon startup. For more details on this mechanism, see: [`_tool/bash.md`](_tool/bash.md).

It is crucial to understand that while many potential "setup" gadgets exist, they only become exploitable vulnerabilities if a corresponding "execution" gadget exists later in the *same pipeline workflow* to complete the chain.
