#
# Distributed Linear Algebra with Future (DLAF)
#
# Copyright (c) ETH Zurich
# All rights reserved.
#
# Please, refer to the LICENSE file in the root directory.
# SPDX-License-Identifier: BSD-3-Clause
#

# Define test executables
set(INIT_TEST_EXECUTABLES init grid1 grid2)
foreach(UPLO lower upper)
  list(APPEND PXPOTRF_TEST_EXECUTABLES pspotrf_${UPLO} pdpotrf_${UPLO}
       pcpotrf_${UPLO} pzpotrf_${UPLO})
  list(APPEND PXPOTRI_TEST_EXECUTABLES pspotri_${UPLO} pdpotri_${UPLO}
       pcpotri_${UPLO} pzpotri_${UPLO})
endforeach()
set(PXHEEVD_TEST_EXECUTABLES pssyevd pdsyevd pcheevd pzheevd)
set(PXHEGVX_TEST_EXECUTABLES pssygvd pdsygvd pchegvd pzhegvd)

find_program(FYPP_PROGRAM fypp)

if(NOT FYPP_PROGRAM)
  message(
    FATAL_ERROR
      "fypp (Fortran preprocessor) not found. fypp is required to build tests.")
endif()

find_package(MPI REQUIRED COMPONENTS Fortran)

if(DLAF_FORTRAN_CSCS_CI)
  set(MPIEXEC_EXECUTABLE "")
  set(MPIEXEC_NUMPROC_FLAG "")
  set(MPIEXEC_MAX_NUMPROCS "")
  set(MPIEXEC_MAX_PREFLAGS "")
else()
  if(NOT (${MPIEXEC_MAX_NUMPROCS} EQUAL 6))
    message(
      FATAL_ERROR
        "Tests run with 6 processes, got ${MPIEXEC_MAX_NUMPROCS}. Set -DMPIEXEC_MAX_NUMPROCS=6."
    )
  endif()
endif()

add_subdirectory(helpers)
add_subdirectory(utils)

set(DLAF_FORTRAN_MPIRUN
    "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS} ${MPIEXEC_PREFLAGS}"
)
separate_arguments(_DLAF_FORTRAN_MPIRUN UNIX_COMMAND ${DLAF_FORTRAN_MPIRUN})

function(add_tests tests library)
  foreach(TEST ${tests})
    add_executable(${TEST} ${TEST}.f90)
    target_link_libraries(${TEST} PRIVATE DLAF_Fortran testutils ${library}
                                          DLAF::SCALAPACK)
    target_compile_options(${TEST} PRIVATE -Wall -Wextra -Wpedantic)
    set(_TEST_COMMAND ${_DLAF_FORTRAN_MPIRUN} $<TARGET_FILE:${TEST}>)
    add_test(NAME ${TEST} COMMAND ${_TEST_COMMAND})
  endforeach()
endfunction()

add_tests("${INIT_TEST_EXECUTABLES}" "")
add_tests("${PXPOTRF_TEST_EXECUTABLES}" pxpotrf)
add_tests("${PXPOTRI_TEST_EXECUTABLES}" pxpotri)
add_tests("${PXHEEVD_TEST_EXECUTABLES}" pxheevd)
add_tests("${PXHEGVX_TEST_EXECUTABLES}" pxhegvd)
