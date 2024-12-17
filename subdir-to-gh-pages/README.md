
Push a directory's contents to gh-pages
=======================================

This action creates a commit on the gh-pages branch with the contents
of the specified directory and pushes the update to the specified
remote.

Usage
-----

```yaml
    steps:
      # upstream steps to build ./docs directory with gh-pages content
      ...
      - uses: metrumresearchgroup/actions/subdir-to-gh-pages@v1
```

Inputs:

 * directory: Directory with contents to absorb to gh-pages branch
   (default: docs)

 * remote: Remote to sync with (default: origin)
