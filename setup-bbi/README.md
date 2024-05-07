
Install and set up bbi
======================

This action installs [bbi][] to `$HOME/bin/bbi` and points the
`BBI_EXE_PATH` environment variable to this location.

[bbi]: https://github.com/metrumresearchgroup/bbi


Usage
-----

```yaml
    steps:
      ...
      - uses: metrumresearchgroup/actions/setup-bbi@v1
        with:
          version: v3.3.0
```

Inputs:

 * version: Version of bbi to install.
