#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) 2018-2024, ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

find_program(FYPP_PROGRAM fypp)

if("${FYPP_PROGRAM}" MATCHES ".*-NOTFOUND")
  message(FATAL_ERROR "fypp (Fortran preprocessor) not found. fypp is required to build tests.")
endif()

find_package(MPI REQUIRED COMPONENTS Fortran)

if(DLAF_FORTRAN_WITH_MKL)
  set(MKL_INTERFACE "lp64" CACHE STRING "")
  set(MKL_THREADING "sequential" CACHE STRING "")
  set(MKL_MPI "mpich" CACHE STRING "")
  set(ENABLE_BLACS "ON" CACHE STRING "")
  set(ENABLE_SCALAPACK "ON" CACHE STRING "")
  find_package(MKL REQUIRED)
else()
  find_package(ScaLAPACK REQUIRED)
endif()

set(DLAF_FORTRAN_MPIRUN "" CACHE STRING "MPI run command.")
separate_arguments(_DLAF_FORTRAN_MPIRUN UNIX_COMMAND ${DLAF_FORTRAN_MPIRUN})

add_subdirectory(helpers)
add_subdirectory(utils)

set(INIT_TEST_EXECUTABLES init)
set(PXPOTRF_TEST_EXECUTABLES pspotrf pdpotrf pcpotrf pzpotrf)
set(PXHEEVD_TEST_EXECUTABLES pssyevd pdsyevd pcheevd pzheevd)
set(PXHEGVX_TEST_EXECUTABLES pssygvx pdsygvx pchegvx pzhegvx)

function(add_tests tests library)
foreach(TEST ${tests})
    add_executable(${TEST} ${TEST}.f90)
    target_link_libraries(${TEST} PRIVATE 
        DLAF_Fortran 
        testutils
        ${library}
    	  $<$<BOOL:${DLAF_FORTRAN_WITH_MKL}>:MKL::MKL> 
    )
    target_compile_options(${TEST} PRIVATE -Wall -Wextra -Wpedantic)
    set(_TEST_COMMAND ${_DLAF_FORTRAN_MPIRUN} $<TARGET_FILE:${TEST}>)
    add_test(NAME ${TEST} COMMAND ${_TEST_COMMAND})
endforeach()
endfunction()


add_tests("${INIT_TEST_EXECUTABLES}" "")
add_tests("${PXPOTRF_TEST_EXECUTABLES}" pxpotrf)
add_tests("${PXHEEVD_TEST_EXECUTABLES}" pxheevd)
add_tests("${PXHEGVX_TEST_EXECUTABLES}" pxhegvx)
