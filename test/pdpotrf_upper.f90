!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pdpotrf_U
   use pxpotrf_tests, only: pdpotrf_U_test

   implicit none

   call pdpotrf_U_test()

end program test_pdpotrf_U
