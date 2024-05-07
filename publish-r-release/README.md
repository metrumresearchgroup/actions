
Publish R package release
=========================

This action creates a CRAN-like repository for the current tag and
publishes it to `s3://mpn.metworx.dev`.


Usage
-----

```yaml
  release:
    if: github.ref_type == 'tag'
    name: Upload release
    needs: check
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: metrumresearchgroup/actions/mpn-latest@v1
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: release
          use-public-rspm: true
          extra-repositories: 'https://mpn.metworx.com/snapshots/stable/${{ env.MPN_LATEST }}'
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgpub
      - uses: metrumresearchgroup/actions/publish-r-release@v1
```

Notes:

 * This job should be restricted to tag pushes.

 * You should set `needs` to any upstream jobs that should succeed
   before the release is created (e.g., a job that runs `R CMD
   check`).

 * Before invoking `publish-r-release`, the main workflow must install
   the package's R depdencies and `pkgpub`.  You may also need to
   install other requirements to build the package (e.g., `bbr` needs
   to install `bbi`).
