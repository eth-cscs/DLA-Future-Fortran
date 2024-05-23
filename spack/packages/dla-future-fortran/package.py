# Copyright 2013-2024 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

# dlaf-no-license-check
from spack.package import *


class DlaFutureFortran(CMakePackage):
    """
    Fortran interface to the DLA-Future library.
    """

    homepage = "https://github.com/eth-cscs/DLA-Future-Fortran"
    url = "https://github.com/eth-cscs/DLA-Future-Fortran/archive/v0.0.0.tar.gz"
    git = "https://github.com/eth-cscs/DLA-Future-Fortran.git"

    maintainers("RMeli", "rasolca", "aurianer")

    license("BSD-3-Clause")

    version("main", branch="main")
    version("0.1.0", sha256="9fd8a105cbb2f3e1daf8a49910f98fce68ca0b954773dba98a91464cf2e7c1da")

    variant("shared", default=True, description="Build shared libraries.")
    variant("test", default=False, description="Build tests.")

    generator("ninja")
    depends_on("cmake@3.22:", type="build")

    depends_on("dla-future@0.4.1: +scalapack")
    depends_on("dla-future +shared", when="+shared")

    depends_on("mpi", when="+test")
    depends_on("py-fypp", when="+test", type="build")

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # FIXME: Variables only available on the DLA-Future-Fortran repo
    # FIXME: Remove those variables from the official Spack package

    variant("cscs-ci", default=False, when="+test", description="Run test in CSCS CI")
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    def cmake_args(self):
        args = []

        args.append(self.define_from_variant("BUILD_SHARED_LIBS", "shared"))
        args.append(self.define_from_variant("DLAF_FORTRAN_BUILD_TESTING", "test"))

        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # FIXME: Variables only available on the DLA-Future-Fortran repo
        # FIXME: Remove those variables from the official Spack package
        args.append(self.define_from_variant("DLAF_FORTRAN_CSCS_CI", "cscs-ci"))
        # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        return args
