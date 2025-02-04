#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2025, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

cmake_minimum_required(VERSION 3.22)

# NOTE: CXX needed with DLA-Future NOTE: C needed with HDF5 (dla-future +hdf5)
project(
  DLAFFortran
  VERSION 0.2.0
  LANGUAGES Fortran C CXX)

include(CMakeDependentOption)
include(GNUInstallDirs)

option(DLAF_FORTRAN_BUILD_TESTING "Build tests" OFF)
cmake_dependent_option(DLAF_FORTRAN_WITH_MKL "Use MKL" OFF
                       "DLAF_FORTRAN_BUILD_TESTING" OFF)
cmake_dependent_option(DLAF_FORTRAN_WITH_MPI_F08 "Use MPI F08 interface" OFF
                       "DLAF_FORTRAN_BUILD_TESTING" OFF)
cmake_dependent_option(DLAF_FORTRAN_CSCS_CI "Use CSCS CI configuration" OFF
                       "DLAF_FORTRAN_BUILD_TESTING" OFF)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE
      "RelWithDebInfo"
      CACHE STRING "Build Type" FORCE)
endif()

if(NOT CMAKE_Fortran_MODULE_DIRECTORY)
  set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/fortran_mods)
endif()

find_package(DLAF 0.6.0 REQUIRED)

add_subdirectory(src)

if(DLAF_FORTRAN_BUILD_TESTING)
  enable_testing()
  add_subdirectory(test)
endif()

# +--------------+
# | Installation |
# +--------------+

set(DEFAULT_CMAKE_INSTALL_MODULEDIR ${CMAKE_INSTALL_INCLUDEDIR})
set(CMAKE_INSTALL_MODULEDIR
    ${DEFAULT_CMAKE_INSTALL_MODULEDIR}
    CACHE STRING "Fortran module installation path")

include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  ${CMAKE_PROJECT_NAME}ConfigVersion.cmake
  VERSION ${PACKAGE_VERSION}
  COMPATIBILITY AnyNewerVersion)

configure_package_config_file(
  ${PROJECT_SOURCE_DIR}/cmake/${CMAKE_PROJECT_NAME}Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME})

install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME})

install(FILES "${CMAKE_Fortran_MODULE_DIRECTORY}/dlaf_fortran.mod"
        DESTINATION ${CMAKE_INSTALL_MODULEDIR})
