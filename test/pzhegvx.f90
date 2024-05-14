!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2024, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pzhegvx
   use pxhegvx_tests, only: pzhegvx_test

   implicit none

   call pzhegvx_test()

end program test_pzhegvx
