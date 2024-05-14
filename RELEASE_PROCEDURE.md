# Release procedure for DLA-Future-Fortran

DLA-Future-Fortran follows [Semantic Versioning](https://semver.org).

1. For minor and major releases: check out the `main` branch. All changes required for the release are
   added to `main` via pull requests. For patch releases: check out the corresponding
   `release-major.minor` branch.

1. Write release notes in `CHANGELOG.md`.

1. Update the version in `CMakeLists.txt`.

1. Update the version and date in `CITATION.cff`.

1. When making a major release, remove deprecated functionality if appropriate.

1. Update the minimum required versions if necessary.

1. Ensure you have [GitHub CLI]() installed. Run `gh auth login` to authenticate with your GitHub account,
   or set the `GITHUB_TOKEN` to a token with `public_repo` access.

1. Create a release on GitHub using the script `scripts/roll_release.sh`.

1. Update spack recipe in `spack/packages/dla-future/package.py` adding the new release.

1. Synchronize [upstream spack
   package](https://github.com/spack/spack/blob/develop/var/spack/repos/builtin/packages/dla-future-fortran/package.py)
   with local repository. Exclude blocks delimited by `###` comments. These are only intended for the
   internal spack package.

1. Delete your `GITHUB_TOKEN` if created only for the release.
