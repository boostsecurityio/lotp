---
layout: tool
title: git
parent: Living Off The Pipeline
nav_order: 1
---

## Living Off The Pipeline - git

`git` is a distributed version control system and the foundation of most CI/CD pipelines. While essential, its complex features can be abused in multiple ways, making it both a powerful "Setup Gadget" and a potential "Execution Gadget".

This analysis covers three distinct vectors, all of which use documented features of `git`.

### Vector 1: `git config` Poisoning (Execution Gadget)

The `git config` command can be used by a "Setup Gadget" to poison the configuration of the local repository. This turns a subsequent, benign `git` command into an RCE trigger.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** Many `git` commands (e.g., `log`, `diff`) use an external pager program. A setup gadget can poison the `core.pager` configuration to point to a malicious script.
*   **Attack Chain:**
    1.  **Setup:** An early step in a pipeline is tricked into running `git config --local core.pager malicious.sh`.
    2.  **Execution:** A later step runs a standard `git log` or `git diff` command. `git` invokes the configured pager, which is now the attacker's malicious script, achieving RCE.

### Vector 2: Arbitrary Symlink Creation (Setup Gadget)

`git` faithfully preserves symbolic links. An attacker can commit a symlink that points to a sensitive location on the CI runner's filesystem.

*   **Primitive:** Arbitrary Symlink Creation.
*   **Mechanism:** The `actions/checkout` step creates the attacker's malicious symlink on the runner's filesystem. A subsequent, seemingly harmless tool (like `tar`) can then be tricked into following the symlink and reading or writing to a sensitive location.

### Vector 3: Git LFS Configuration (Data Exfiltration Gadget)

The Git LFS (Large File Storage) extension uses a `.lfsconfig` file to define the LFS server URL. An attacker can modify this file to exfiltrate credentials.

*   **Primitive:** Arbitrary Network Access (Data Exfiltration).
*   **Mechanism:** An attacker points the LFS URL in `.lfsconfig` to their own server. When `actions/checkout` runs with `lfs: true`, the `git lfs` client sends a request to the attacker's server, which includes an `Authorization` header containing the job's `GITHUB_TOKEN`.

### References

*   [Git Configuration](https://git-scm.com/docs/git-config)
*   [Git LFS Documentation](https://git-lfs.github.com/)
