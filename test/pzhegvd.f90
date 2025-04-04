!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pzhegvd
   use pxhegvd_tests, only: pzhegvd_test

   implicit none

   call pzhegvd_test()

end program test_pzhegvd
