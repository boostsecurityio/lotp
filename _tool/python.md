---
title: python
tags:
  - cli
  - env-var
references: 
- https://docs.python.org/3/using/cmdline.html#environment-variables
files: []
---

`python` is used to execute Python programs.

## Environement variable poisoning

By default, `python` doesn't load any configuration files in the current directory. However, if we're able to poison multiple environment variables, we can gain code execution before any `python`/`pip` invocation through the `$PYTHONWARNINGS` environment variable.

This environment variable, while usually intended to control Python warnings, lets us load a Python module by name through the `category` section. We can use this to load the `antigravity` module which is an easter egg that opens an [xkcd](https://xkcd.com/) comic in your favorite browser.

![https://xkcd.com/353/](https://imgs.xkcd.com/comics/python.png)

To open the comic in a web browser, `antigravity` relies on the `webbrowser` module which in turn uses the `$BROWSER` environment variable (if configured) to choose an executable with which to open the comic URL.

From there, the chain can be adapted depending on the available utilities, but here is a functional example with bash:

```bash
PYTHONWARNINGS="::antigravity.::"
BROWSER="/bin/bash"
BASH_ENV="$(f=$(mktemp);echo pwned; echo exit>$f; echo $f)"
```

> While `$(echo pwned)` would've been sufficient as an assignment to `$BASH_ENV`, the additional commands ensure that the invocation to `/bin/bash` returns a successful status code which prevents the opening of an additional browser.