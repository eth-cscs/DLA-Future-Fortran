!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2025, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pssyevd
   use pxheevd_tests, only: pssyevd_test

   implicit none

   call pssyevd_test()

end program test_pssyevd
