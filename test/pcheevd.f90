!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pcheevd
   use pxheevd_tests, only: pcheevd_test

   implicit none

   call pcheevd_test()

end program test_pcheevd
