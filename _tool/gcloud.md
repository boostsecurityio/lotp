---
title: gcloud
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://cloud.google.com/build/docs/configuring-builds/create-basic-configuration 
files: [cloudbuild.yaml]
---

`gcloud` is the Google Cloud management tool configured through a file in some cases.

## `gcloud builds submit`

An attacker-controlled `cloudbuild.yaml` can be used to compromise the remote build pipeline, which has the same permission as the authenticated account:

```yaml
steps:
  - name: 'alpine'
    args: ['sh', '-c', 'id']
```
