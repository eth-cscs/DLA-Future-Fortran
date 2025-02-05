!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2025, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pspotrf
   use pxpotrf_tests, only: pspotrf_test

   implicit none

   call pspotrf_test()

end program test_pspotrf
