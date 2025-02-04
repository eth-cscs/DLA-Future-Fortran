#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2025, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

add_library(DLAF_Fortran dlaf_fortran.f90)

target_compile_options(DLAF_Fortran PRIVATE -Wall -Wextra -Wpedantic)

target_link_libraries(
  DLAF_Fortran
  PRIVATE DLAF::DLAF
)

set_property(TARGET DLAF_Fortran PROPERTY EXPORT_NAME Fortran) # DLAF::Fortran

install(
  TARGETS DLAF_Fortran
  EXPORT ${CMAKE_PROJECT_NAME}-Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(EXPORT ${CMAKE_PROJECT_NAME}-Targets
        NAMESPACE DLAF::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}
)
