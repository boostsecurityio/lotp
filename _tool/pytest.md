---
title: pytest
tags:
- cli
- config-file
- eval-python
references:
- https://docs.pytest.org/en/stable/
files:
- *_test.py
- test_*.py
---

Pytest is a framework that simplifies testing Python projects. It runs test files (e.g., `test_*.py` or `*_test.py`) and executes functions within them that are prefixed with `test_`. If a test fails (e.g., with `assert False`), pytest displays the captured stdout from that test.

`test_pwn.py`

```python
import os
def test_pwn():
    os.system("id")
    assert False
```
