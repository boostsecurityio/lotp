---
layout: tool
title: xmllint
parent: Living Off The Pipeline
nav_order: 32
---

## Living Off The Pipeline - xmllint

`xmllint` is a command-line tool for parsing and validating XML files. It can be abused as a "Living Off The Pipeline" (LOTP) gadget to read arbitrary files from the filesystem through an XML External Entity (XXE) attack.

### First-Order LOTP Gadget

`xmllint` is a **First-Order LOTP Gadget**. It provides an "Arbitrary File Read" primitive when it processes a malicious XML file with specific flags.

#### Malicious Primitive: Arbitrary File Read

The vulnerability is triggered when `xmllint` is run with the `--noent` flag. This flag instructs the parser to substitute and expand entities. An attacker can craft an XML file that defines an external entity using a `file://` URI to point to a sensitive file on the local system.

When `xmllint` processes this file with the `--noent` flag, it reads the contents of the specified local file and prints them to standard output, where they can be captured by CI/CD logs.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing a malicious XML file.
    ```xml
    <!-- data.xml -->
    <?xml version="1.0"?>
    <!DOCTYPE foo [
      <!ENTITY xxe SYSTEM "file:///etc/passwd">
    ]>
    <data>&xxe;</data>
    ```

2.  **Vulnerable Workflow:** The pipeline contains a command to validate the XML file, using the `--noent` flag.
    ```yaml
    - name: Validate XML data
      run: xmllint --noent data.xml
    ```

3.  **Execution:**
    *   The `xmllint --noent data.xml` command is executed.
    *   The parser reads the attacker's XML file and encounters the `&xxe;` entity.
    *   Because `--noent` is active, it resolves the entity by reading the contents of `/etc/passwd`.
    *   The contents of the file are substituted into the XML structure and printed to standard output.
    *   The CI/CD system logs the output, exfiltrating the sensitive file.

This attack is dangerous because the CI/CD command appears to be a safe validation step. The malicious payload is hidden in a data file, and the vulnerability is triggered by a seemingly innocuous command-line flag.

### References

*   [OWASP: XML External Entity (XXE) Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)
*   `xmllint` man page
