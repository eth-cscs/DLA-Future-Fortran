# Copyright 2013-2024 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# dlaf-no-license-check
from spack import *


class DlaFutureFortran(CMakePackage):
    """
    Fortran interface to the DLA-Future library.
    """

    homepage = "https://github.com/eth-cscs/DLA-Future-Fortran"
    url      = "http://www.example.com/MyPackage-1.0.tar.gz"
    git = "https://github.com/eth-cscs/DLA-Future-Fortran"

    maintainers("RMeli")
    
    license("BSD-3-Clause")

    version("main")

    variant("shared", default=True, description="Build shared libraries.")
    variant("test", default=False, description="Build tests.")

    generator("ninja")
    depends_on("cmake@3.22:", type="build")

    # Requires 0.3.0 for complex API
    # Requires 0.4.0 for Intel OneAPI MKL
    depends_on("dla-future@0.4.0: +scalapack")

    depends_on("mpi", when="+test")
    depends_on("scalapack", when="+test")
    depends_on("py-fypp", when="+test", type="build")

    def cmake_args(self):
        args = []

        args.append(self.define_from_variant("BUILD_SHARED_LIBS", "shared"))

        if self.spec.satisfies("+test"):
            args.append(self.define("DLAF_FORTRAN_BUILD_TESTING", True))
            if self.spec.satisfies("^intel-oneapi-mkl"):
                args.append(self.define("DLAF_FORTRAN_WITH_MKL", "ON"))

        return args
