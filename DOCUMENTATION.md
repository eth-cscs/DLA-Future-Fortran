# DLA-Future-Fortran Documentation

## Documentation

* [main](https://eth-cscs.github.io/DLA-Future-Fortran/main/)
* [`v0.5.0`](https://eth-cscs.github.io/DLA-Future-Fortran/v0.5.0/)
* [`v0.4.0`](https://eth-cscs.github.io/DLA-Future-Fortran/v0.4.0/)
* [`v0.3.0`](https://eth-cscs.github.io/DLA-Future-Fortran/v0.3.0/)

## How to generate the documentation

Install Python dependencies:

```bash
python -m pip install -r requirements.txt
```

The Fortran code is documented using [FORD] (FORtran Documenter), an automatic documentation generator for modern Fortran projects.

```bash
python -m ford DLA-Future-Fortran.md
```

By default, the documentation is generated in the `doc-ford` directory.

## Documentation on GitHub

The documentation is hosted on [GitHub Pages]. Documentation is generated automatically by the [GitHub Action] `.github/workflows/docs.yaml` for each version (`v*` tag) and for the `main` branch.

The documentation is pushed by the [GitHub Action] to the `docs-ghpages` branch. This branch was manually created as an orphan branch with

```bash
git checkout --orphan docs-ghpages
mkdir main && touch main/index.html
git rm --cached -r . && git add main/index.html && git commit -m "empty docs" 
git push --set-upstream origin docs-ghpages
```

[GitHub Pages]: https://pages.github.com
[FORD]: https://forddocs.readthedocs.io/en/latest/
