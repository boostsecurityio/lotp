---
title: pytest
tags:
- cli
- config-file
- eval-python
references:
- https://docs.pytest.org/en/stable/
files:
- *.py
---

Pytest is a framework to ease testing of python project. It will run any `test_something.py` if it contains a `test_` function. `assert False` will show the stdout.

`test_pwn.py`

```python
import os
def test_pwn():
    os.system("id")
    assert False
```
