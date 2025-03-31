!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2025, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program init
   use dlaf_fortran, only: dlaf_initialize, dlaf_finalize
   use testutils, only: setup_mpi, teardown_mpi

   implicit none

   integer :: rank, numprocs
   integer:: nprow, npcol

   nprow = 2
   npcol = 3

   call setup_mpi(nprow, npcol, rank, numprocs)

   ! You can call dlaf_initialize() multiple times
   ! If DLA-Future is already initialized, dlaf_initialize() does nothing
   call dlaf_initialize()
   call dlaf_initialize()

   ! You can call dlaf_finalize() multiple times
   ! If DLA-Future is not initialized, dlaf_finalize() does nothing
   call dlaf_finalize()
   call dlaf_finalize()

   call teardown_mpi()

end program init
