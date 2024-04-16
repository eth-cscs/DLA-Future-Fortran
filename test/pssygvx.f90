!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2024, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

program test_pssygvx
   use pxhegvx_tests, only: pssygvx_test

   implicit none

   call pssygvx_test()

end program test_pssygvx
