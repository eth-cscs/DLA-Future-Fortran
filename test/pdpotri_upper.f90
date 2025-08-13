!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pdpotri_U
   use pxpotri_tests, only: pdpotri_U_test

   implicit none

   call pdpotri_U_test()

end program test_pdpotri_U
