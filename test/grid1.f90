!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program grid1
   use dlaf_fortran, only: dlaf_initialize, dlaf_finalize
   use dlaf_fortran, only: dlaf_create_grid_from_blacs, dlaf_free_grid
   use testutils, only: setup_mpi, teardown_mpi

   implicit none

   external blacs_get
   external blacs_gridinit

   integer :: rank, numprocs
   integer:: nprow, npcol
   integer :: ictxt_0, ictxt_1

   nprow = 2
   npcol = 3

   call setup_mpi(nprow, npcol, rank, numprocs)

   ! Get default system context
   call blacs_get(0, 0, ictxt_0)
   call blacs_get(0, 0, ictxt_1)

   call blacs_gridinit(ictxt_0, 'R', nprow, npcol)
   call blacs_gridinit(ictxt_1, 'C', nprow, npcol)

   call dlaf_initialize()
   call dlaf_create_grid_from_blacs(ictxt_0)
   call dlaf_create_grid_from_blacs(ictxt_1)
   call dlaf_free_grid(ictxt_0)
   call dlaf_free_grid(ictxt_1)
   call dlaf_finalize()

   call teardown_mpi()

end program grid1
