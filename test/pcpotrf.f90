!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2024, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pcpotrf
   use pxpotrf_tests, only: pcpotrf_test

   implicit none

   call pcpotrf_test()

end program test_pcpotrf
