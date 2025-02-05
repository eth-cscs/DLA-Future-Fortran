# DLA-Future Fortran Interface

 [![zenodo](https://zenodo.org/badge/DOI/10.5281/zenodo.11241331.svg)](https://doi.org/10.5281/zenodo.11241331) [![pipeline status](https://gitlab.com/cscs-ci/ci-testing/webhook-ci/mirrors/657496524998283/7598378243915359/badges/main/pipeline.svg)](https://gitlab.com/cscs-ci/ci-testing/webhook-ci/mirrors/657496524998283/7598378243915359/-/commits/main)

Fortran interface for [DLA-Future], a task-based linear algebra library providing GPU-enabled distributed eigensolver.

## Documentation

[DLA-Future-Fortran `main` Documentation](https://eth-cscs.github.io/DLA-Future-Fortran/main/).
[DLA-Future-Fortran `v0.3.0` Documentation](https://eth-cscs.github.io/DLA-Future-Fortran/v0.3.0/)

## Citation

If you are using DLA-Future-Fortran, please cite the following conference paper in addition to this repository and the [DLA-Future] repository:

```
@InProceedings{10.1007/978-3-031-61763-8_13,
    author="Solc{\`a}, Raffaele
        and Simberg, Mikael
        and Meli, Rocco
        and Invernizzi, Alberto
        and Reverdell, Auriane
        and Biddiscombe, John",
    editor="Diehl, Patrick
        and Schuchart, Joseph
        and Valero-Lara, Pedro
        and Bosilca, George",
    title="DLA-Future: A Task-Based Linear Algebra Library Which Provides a GPU-Enabled Distributed Eigensolver",
    booktitle="Asynchronous Many-Task Systems and Applications",
    year="2024",
    publisher="Springer Nature Switzerland",
    address="Cham",
    pages="135--141",
    isbn="978-3-031-61763-8"
}
```

## Acknowledgements

The development of [DLA-Future-Fortran] is supported by the following organizations:

* [CSCS]: Swiss National Supercomputing Center
* [ETH Zurich]: Swiss Federal Institute of Technology Zurich
* [PASC]: Platform for Advanced Scientific Computing

<img height="50" src="./docs/images/logo-cscs.jpg"><img height="50" src="./docs/images/logo-eth.svg"><img height="50" src="./docs/images/logo-pasc.png">

[DLA-Future]: https://github.com/eth-cscs/DLA-Future
[pika]: https://pikacpp.org/
[DLA-Future-Fortran]: https://github.com/eth-cscs/DLA-Future-Fortran
[CSCS]: https://www.cscs.ch
[ETH Zurich]: https://ethz.ch/en.html
[PASC]: https://www.pasc-ch.org/
