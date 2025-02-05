#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2025, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

set(fyppFiles testutils.fypp)

foreach(infileName IN LISTS fyppFiles)

  string(REGEX REPLACE ".fypp\$" ".f90" outfileName "${infileName}")

  set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${outfileName}")
  set(infile "${CMAKE_CURRENT_SOURCE_DIR}/${infileName}")

  add_custom_command(
    OUTPUT "${outfile}"
    COMMAND "${FYPP_PROGRAM}" "${infile}" "${outfile}"
    MAIN_DEPENDENCY "${infile}"
    VERBATIM)

  get_filename_component(modName ${outfileName} NAME_WE)

  add_library(${modName} ${outfileName})
  target_compile_options(${modName} PRIVATE -Wall -Wextra -Wpedantic)
  target_link_libraries(${modName} PRIVATE MPI::MPI_Fortran)
  target_compile_definitions(
    ${modName}
    PRIVATE $<$<BOOL:${DLAF_FORTRAN_WITH_MPI_F08}>:DLAF_FORTRAN_WITH_MPI_F08>)
  # Use preprocessor on .f90 files
  set_target_properties(${modName} PROPERTIES Fortran_PREPROCESS "ON")
endforeach()
