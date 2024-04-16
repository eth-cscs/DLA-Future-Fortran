#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2024, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

set(fppFiles pxpotrf.fpp pxheevd.fpp pxhegvx.fpp)

foreach(infileName IN LISTS fppFiles)

    string(REGEX REPLACE ".fpp\$" ".f90" outfileName "${infileName}")

    set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${outfileName}")
    set(infile "${CMAKE_CURRENT_SOURCE_DIR}/${infileName}")

    add_custom_command(
        OUTPUT "${outfile}"
        COMMAND fypp "${infile}" "${outfile}"
        MAIN_DEPENDENCY "${infile}"
        VERBATIM)

    get_filename_component(modName ${outfileName} NAME_WE)

    add_library(${modName} ${outfileName})
    target_link_libraries(${modName} PRIVATE 
        DLAF_Fortran 
        testutils
        MPI::MPI_Fortran 
        $<$<BOOL:${DLAF_FORTRAN_WITH_MKL}>:MKL::MKL> 
    )

endforeach()
