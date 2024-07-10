# DLA-Future-Fortran Documentation

## Documentation

* [main]()

## How to generate the documentation

The Fortran code is documented using [FORD] (FORtran Documenter), an automatic documentation generator for modern Fortran projects.

```bash
python -m ford --output_dir documentation DLA-Future-Fortran.md
```

## Documentation on GitHub

The documentation is hosted on [GitHub Pages]. Documentation is generated automatically by the [GitHub Action] `.github/workflows/docs.yaml`
for each version (`v*` tag) and for the `main` branch.

The documentation is pushed by the [GitHub Action] to the `docs-ghpages` branch. This branch was manually created as an orphan branch with

```bash
git checkout --orphan docs-ghpages
git push
```

[GitHub Pages]: https://pages.github.com
[FORD]: https://forddocs.readthedocs.io/en/latest/
