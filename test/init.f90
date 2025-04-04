!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program hello
   use dlaf_fortran, only: dlaf_initialize, dlaf_finalize
   use testutils, only: setup_mpi, teardown_mpi

   implicit none

   integer :: rank, numprocs
   integer:: nprow, npcol

   nprow = 2
   npcol = 3

   call setup_mpi(nprow, npcol, rank, numprocs)

   call dlaf_initialize()
   call dlaf_finalize()

   call teardown_mpi()

end program hello
