!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pchegvd
   use pxhegvd_tests, only: pchegvd_test

   implicit none

   call pchegvd_test()

end program test_pchegvd
