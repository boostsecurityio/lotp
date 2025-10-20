---
layout: tool
title: gsutil
parent: Living Off The Pipeline
nav_order: 37
---

## Living Off The Pipeline - gsutil

`gsutil` is the command-line tool for Google Cloud Storage. While its own configuration is secure, its `rsync` command can be abused to create a malicious state on the filesystem, making it a "Living Off The Pipeline" (LOTP) "Setup Gadget".

### First-Order LOTP Gadget (Setup Gadget)

`gsutil` is a **First-Order LOTP Gadget**. It does not provide a direct RCE or file write primitive, but it can be used to place a malicious symbolic link on the CI runner's filesystem, which can then be exploited by a subsequent tool.

#### Malicious Primitive: Arbitrary Symlink Creation

The `gsutil rsync` command is used to synchronize directories between a source and a destination. Unlike some versions of standard `rsync`, `gsutil rsync` does not follow symbolic links by default; it copies them as-is. This behavior can be abused by an attacker.

An attacker can place a malicious symlink in a directory that is the source of a `gsutil rsync` operation. The command will then faithfully copy this symlink to the destination on the CI runner. This symlink can point to a sensitive file or directory anywhere on the runner's filesystem.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing a malicious symbolic link.
    ```bash
    # Attacker creates a symlink in their local repository
    ln -s /etc/passwd sensitive-data.txt
    ```

2.  **Vulnerable Workflow:** The pipeline contains two steps: one to back up the repository to a GCS bucket, and a later step that archives a different directory.
    ```yaml
    - name: Back up source code to GCS
      run: gsutil rsync -r . gs://my-backup-bucket/src/

    # ... other steps ...

    - name: Archive build artifacts
      # This step will be tricked by a symlink created in the first step
      run: tar -czf artifacts.tar.gz build/
    ```
    Let's assume a previous step in the pipeline was tricked into creating a symlink `build/malicious-link` -> `/etc/passwd`. A more direct example is where the `gsutil rsync` itself creates the dangerous state for a later tool.

3.  **Execution (Setup):**
    *   The `gsutil rsync` command runs, copying the contents of the repository to the backup bucket. In doing so, it creates the `sensitive-data.txt` symlink on the runner's filesystem (if the source was the bucket) or uploads it (if the source was local).

4.  **Execution (Abuse):**
    *   A later command, like `tar`, is run on a directory that now contains the attacker's symlink.
    *   `tar` follows the symlink and includes the contents of the sensitive file (`/etc/passwd`) in its archive.
    *   If this archive is uploaded as a build artifact, the attacker can download it and access the exfiltrated file.

### References

*   [gsutil rsync documentation](https://cloud.google.com/storage/docs/gsutil/commands/rsync)
