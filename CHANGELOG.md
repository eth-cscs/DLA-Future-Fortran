# Changelog

## DLA-Future-Fortran 0.3.0

### Added

* Documentation with [Ford] [PR #X]
* Calculation of partial eigenspectrum [PR #26]
* `libs` property to Spack package [PR #25]
* `pkgconfig` as build dependency to Spack package [PR #23]

## DLA-Future-Fortran 0.2.0

### Added

* Generalized eigensolver for an already factorized $\mathbf{B}$ matrix [PR #18]

### Changed

* Name of the generalized eigenvalue solver from `*gvx` to `*gvd` [PR #16]

### Fixed

* Spack installation with `+test` variant by setting `-DMPIEXEC_MAX_NUMPROCS=6` [PR #10]

## DLA-Future-Fortran 0.1.0

First release of [DLA-Future-Fortran], a Fortran interface for [DLA-Future].

[DLA-Future]: https://github.com/eth-cscs/DLA-Future
[DLA-Future-Fortran]: https://github.com/eth-cscs/DLA-Future-Fortran 
[Ford]: https://forddocs.readthedocs.io/en/stable/
