#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2024, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

set(DLAF_FORTRAN_MPIRUN "" CACHE STRING "MPI run command.")
separate_arguments(_DLAF_FORTRAN_MPIRUN UNIX_COMMAND ${DLAF_FORTRAN_MPIRUN})

add_subdirectory(utils)
add_subdirectory(fpp)

set(TEST_EXECUTABLES
    init
    pspotrf pdpotrf pcpotrf pzpotrf
    pssyevd pdsyevd pcheevd pzheevd
    pssygvx pdsygvx pchegvx pzhegvx
)

foreach(TEST ${TEST_EXECUTABLES})
    add_executable(${TEST} ${TEST}.f90)
    target_link_libraries(${TEST} PRIVATE 
        DLAF_Fortran 
        testutils
        pxpotrf
        pxheevd
        pxhegvx
    	  $<$<BOOL:${DLAF_FORTRAN_WITH_MKL}>:MKL::MKL> 
    )
    target_compile_options(${TEST} PRIVATE -Wall -Wextra -Wpedantic)
    set(_TEST_COMMAND ${_DLAF_FORTRAN_MPIRUN} $<TARGET_FILE:${TEST}>)
    add_test(NAME ${TEST} COMMAND ${_TEST_COMMAND})
endforeach()
