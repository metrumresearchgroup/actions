
Find latest MPN snapshot
=========================

This action queries <https://mpn.metworx.com> to find latest MPN
snapshot and sets the `MPN_LATEST` environment variable to the result.


Usage
-----

```yaml
    steps:
      ...
      - uses: metrumresearchgroup/actions/mpn-latest@v1
      # Example downstream step that uses the environment variable.
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: release
          use-public-rspm: true
          extra-repositories: 'https://mpn.metworx.com/snapshots/stable/${{ env.MPN_LATEST }}'
```
