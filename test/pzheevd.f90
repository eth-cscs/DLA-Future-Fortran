!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pzheevd
   use pxheevd_tests, only: pzheevd_test

   implicit none

   call pzheevd_test()

end program test_pzheevd
