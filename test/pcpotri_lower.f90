!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pcpotri_L
   use pxpotri_tests, only: pcpotri_L_test

   implicit none

   call pcpotri_L_test()

end program test_pcpotri_L
