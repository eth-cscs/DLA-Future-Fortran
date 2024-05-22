!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2024, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

module dlaf_fortran

   use iso_fortran_env, only: dp => real64, sp => real32

   use iso_c_binding, only: &
      c_char, &
      c_double, &
      c_int, &
      c_loc, &
      c_ptr, &
      c_signed_char, &
      c_null_char

   implicit none

   private

   public :: dlaf_initialize, dlaf_finalize
   public :: dlaf_create_grid_from_blacs, dlaf_free_grid
   public :: dlaf_pspotrf, dlaf_pdpotrf, dlaf_pcpotrf, dlaf_pzpotrf
   public :: dlaf_pssyevd, dlaf_pdsyevd, dlaf_pcheevd, dlaf_pzheevd
   public :: dlaf_pssygvx, dlaf_pdsygvx, dlaf_pchegvx, dlaf_pzhegvx

contains

   subroutine dlaf_initialize()
      !! Initialize DLA-Future and pika
      !!
      !! @note
      !! If DLA-Future has already been initialized, this function does nothing.
      !! @endnote

      integer, parameter :: dlaf_argc = 1, pika_argc = 1

      character(len=5, kind=c_char), allocatable, target :: dlaf_argv(:), pika_argv(:)
      type(c_ptr), allocatable, dimension(:) :: dlaf_argv_ptr, pika_argv_ptr

      interface
         subroutine dlaf_initialize_c(pika_argc_, pika_argv_, dlaf_argc_, dlaf_argv_) bind(C, name='dlaf_initialize')
            import :: c_ptr, c_int
            type(c_ptr), dimension(*) :: pika_argv_
            type(c_ptr), dimension(*) :: dlaf_argv_
            integer(kind=c_int), value :: pika_argc_
            integer(kind=c_int), value :: dlaf_argc_
         end subroutine dlaf_initialize_c
      end interface

      allocate (pika_argv(pika_argc))
      pika_argv(1) = "dlaf"//c_null_char
      allocate (dlaf_argv(dlaf_argc))
      dlaf_argv(1) = "dlaf"//c_null_char

      allocate (pika_argv_ptr(pika_argc))
      pika_argv_ptr(1) = c_loc(pika_argv(1))
      allocate (dlaf_argv_ptr(dlaf_argc))
      dlaf_argv_ptr(1) = c_loc(dlaf_argv(1))

      call dlaf_initialize_c(pika_argc, pika_argv_ptr, dlaf_argc, dlaf_argv_ptr)

   end subroutine dlaf_initialize

   subroutine dlaf_finalize()
      !! Finalize DLA-Future and pika
      !!
      !! @note
      !! If DLA-Future has already been finalized, this function does nothing.
      !! @endnote

      interface
         subroutine dlaf_finalize_c() bind(C, name='dlaf_finalize')
         end subroutine dlaf_finalize_c
      end interface

      call dlaf_finalize_c()

   end subroutine dlaf_finalize

   subroutine dlaf_create_grid_from_blacs(blacs_context)
      !! Create DLA-Future grid from existing BLACS context
      !!
      !! @warning
      !! The grid ordering is automatically inferred from the BLACS grid ordering. Only row-major and column-major
      !! grids are supported (created with `blacs_gridinit`). Grids created with `blacs_gridmap` are _not_ supported.
      !! @endwarning

      integer, intent(in) :: blacs_context
        !! BLACS context

      interface
         subroutine dlaf_create_grid_from_blacs_c(blacs_contxt) bind(C, name='dlaf_create_grid_from_blacs')
            import :: c_int
            integer(kind=c_int), value :: blacs_contxt
         end subroutine dlaf_create_grid_from_blacs_c
      end interface

      call dlaf_create_grid_from_blacs_c(blacs_context)

   end subroutine dlaf_create_grid_from_blacs

   subroutine dlaf_free_grid(blacs_context)
      !! Free DLA-Future grid corresponding to given BLACS context
      !!
      !! @warning
      !! Only the DLA-Future internal grid is freed. The associated BLACS grid will need to be freed explicitly
      !! with `blacs_gridexit`.
      !! @endwarning

      integer, intent(in) :: blacs_context
        !! BLACS context

      interface
         subroutine dlaf_free_grid_c(blacs_contxt) bind(C, name='dlaf_free_grid')
            import :: c_int
            integer(kind=c_int), value :: blacs_contxt
         end subroutine dlaf_free_grid_c
      end interface

      call dlaf_free_grid_c(blacs_context)

   end subroutine dlaf_free_grid

   subroutine dlaf_pspotrf(uplo, n, a, ia, ja, desca, info)
      !! Cholesky decomposition for a distributed single-precision real symmetric positive definite matrix \(\mathbf{A}\)
      !!
      !! @note
      !! The input matrix is assumed to be distributed in host memory. Moving to and from GPU memory is
      !! handled internally.
      !! @endnote

      character, intent(in) :: uplo
      integer, intent(in) :: n
        !! Order of the matrix sub-matrix \(\mathbf{A}\) used in the computation
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
        !! Local part of the global matrix \(\mathbf{A}\)
      integer, intent(in) :: ia
        !! Row index of the global matrix identifying the first row of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: ja
        !! Column index of the global matrix identifying the first column of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: desca
        !! ScaLAPACK descriptor of the global matrix \(\mathbf{A}\)
      integer, target, intent(out) :: info
        !! `0` if the Cholesky decomposition completed normally

      interface
         subroutine dlaf_pspotrf_c(uplo_, n_, a_, ia_, ja_, desca_, info_) &
            bind(C, name='dlaf_pspotrf')

            import :: c_ptr, c_int, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: ia_, ja_, n_
            type(c_ptr), value :: info_
            integer(kind=c_int), dimension(*) :: desca_
            type(c_ptr), value :: a_
         end subroutine dlaf_pspotrf_c
      end interface

      call dlaf_pspotrf_c(iachar(uplo, c_signed_char), n, c_loc(a(1, 1)), ia, ja, desca, c_loc(info))

   end subroutine dlaf_pspotrf

   subroutine dlaf_pdpotrf(uplo, n, a, ia, ja, desca, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n
      real(kind=dp), dimension(:, :), target, intent(inout) :: a
      integer, intent(in) :: ia, ja
      integer, dimension(9), intent(in) :: desca
      integer, target, intent(out) :: info

      interface
         subroutine dlaf_pdpotrf_c(uplo_, n_, a_, ia_, ja_, desca_, info_) &
            bind(C, name='dlaf_pdpotrf')

            import :: c_ptr, c_int, c_double, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: ia_, ja_, n_
            type(c_ptr), value :: info_
            integer(kind=c_int), dimension(*) :: desca_
            type(c_ptr), value :: a_
         end subroutine dlaf_pdpotrf_c
      end interface

      call dlaf_pdpotrf_c(iachar(uplo, c_signed_char), n, c_loc(a(1, 1)), ia, ja, desca, c_loc(info))

   end subroutine dlaf_pdpotrf

   subroutine dlaf_pcpotrf(uplo, n, a, ia, ja, desca, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a
      integer, intent(in) :: ia, ja
      integer, dimension(9), intent(in) :: desca
      integer, target, intent(out) :: info

      interface
         subroutine dlaf_pcpotrf_c(uplo_, n_, a_, ia_, ja_, desca_, info_) &
            bind(C, name='dlaf_pcpotrf')

            import :: c_ptr, c_int, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: ia_, ja_, n_
            type(c_ptr), value :: info_
            integer(kind=c_int), dimension(*) :: desca_
            type(c_ptr), value :: a_
         end subroutine dlaf_pcpotrf_c
      end interface

      call dlaf_pcpotrf_c(iachar(uplo, c_signed_char), n, c_loc(a(1, 1)), ia, ja, desca, c_loc(info))

   end subroutine dlaf_pcpotrf

   subroutine dlaf_pzpotrf(uplo, n, a, ia, ja, desca, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a
      integer, intent(in) :: ia, ja
      integer, dimension(9), intent(in) :: desca
      integer, target, intent(out) :: info

      interface
         subroutine dlaf_pzpotrf_c(uplo_, n_, a_, ia_, ja_, desca_, info_) &
            bind(C, name='dlaf_pzpotrf')

            import :: c_ptr, c_int, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: ia_, ja_, n_
            type(c_ptr), value :: info_
            integer(kind=c_int), dimension(*) :: desca_
            type(c_ptr), value :: a_
         end subroutine dlaf_pzpotrf_c
      end interface

      call dlaf_pzpotrf_c(iachar(uplo, c_signed_char), n, c_loc(a(1, 1)), ia, ja, desca, c_loc(info))

   end subroutine dlaf_pzpotrf

   subroutine dlaf_pssyevd(uplo, n, a, ia, ja, desca, w, z, iz, jz, descz, info)
      !! Eigensolver for a distributed single-precision real symmetric matrix \(\mathbf{A}\)
      !!
      !! @note
      !! The input matrix and the matrix of eigenvectors are assumed to be distributed in host memory.
      !! Moving to and from GPU memory is handled internally.
      !! @endnote
      !!
      !! @note
      !! The vector of eigenvalues is assumed to be local (non-distributed) and in host memory.
      !! Moving to and from GPU memory is handled internally.
      !! @endnote
      !!
      !! @note
      !! The pika runtime is resumed when this function is called and suspended when the call terminates.
      !! @endnote

      character, intent(in) :: uplo
        !! Indicates whether the upper (`"U"`) or lower (`"L"`) triangular part of the global sub-matrix
        !! \(\mathbf{A}\) is referenced
      integer, intent(in) :: n
        !! Order of the sub-matrix \(\mathbf{A}\) used in the computation
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
        !! Local part of the global matrix \(\mathbf{A}\)
      integer, intent(in) :: ia
        !! Row index in the global matrix identifying the first row of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: ja
        !! Column index in the global matrix identifying the first column of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: desca
        !! ScaLAPACK descriptor of the gloabl matrix \(\mathbf{A}\)
      real(kind=sp), dimension(:), target, intent(out) :: w
        !! Local (non-distributed) vector of eigenvalues
      real(kind=sp), dimension(:, :), target, intent(inout) :: z
        !! Local part of the global matrix \(\mathbf{Z}\)
      integer, intent(in) :: iz
        !! Row index in the global matrix identifying the first row of the sub-matrix \(\mathbf{Z}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: jz
        !! Column index in the global matrix identifying the first column of the sub-matrix \(\mathbf{Z}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: descz
        !! ScaLAPACK descriptor of the gloabl matrix \(\mathbf{Z}\)
      integer, target, intent(out) :: info
        !! `0` if the eigensolver completed normally

      interface
         subroutine dlaf_pssyevd_c(uplo_, n_, a_, ia_, ja_, desca_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pssyevd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, iz_, jz_
            type(c_ptr), value :: a_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pssyevd_c
      end interface

      info = -1

      call dlaf_pssyevd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pssyevd

   subroutine dlaf_pdsyevd(uplo, n, a, ia, ja, desca, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, iz, jz
      integer, dimension(9), intent(in) :: desca, descz
      integer, target, intent(out) :: info
      real(kind=dp), dimension(:, :), target, intent(inout) :: a, z
      real(kind=dp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pdsyevd_c(uplo_, n_, a_, ia_, ja_, desca_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pdsyevd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, iz_, jz_
            type(c_ptr), value :: a_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pdsyevd_c
      end interface

      info = -1

      call dlaf_pdsyevd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pdsyevd

   subroutine dlaf_pcheevd(uplo, n, a, ia, ja, desca, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, iz, jz
      integer, dimension(9), intent(in) :: desca, descz
      integer, target, intent(out) :: info
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a, z
      real(kind=sp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pcheevd_c(uplo_, n_, a_, ia_, ja_, desca_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pcheevd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, iz_, jz_
            type(c_ptr), value :: a_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pcheevd_c
      end interface

      info = -1

      call dlaf_pcheevd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pcheevd

   subroutine dlaf_pzheevd(uplo, n, a, ia, ja, desca, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, iz, jz
      integer, dimension(9), intent(in) :: desca, descz
      integer, target, intent(out) :: info
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a, z
      real(kind=dp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pzheevd_c(uplo_, n_, a_, ia_, ja_, desca_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pzheevd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, iz_, jz_
            type(c_ptr), value :: a_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pzheevd_c
      end interface

      info = -1

      call dlaf_pzheevd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pzheevd

   subroutine dlaf_pssygvx(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed symmetric-definite eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !!
      !! @note
      !! The input matrix and the matrix of eigenvectors are assumed to be distributed in host memory.
      !! Moving to and from GPU memory is handled internally.
      !! @endnote
      !!
      !! @note
      !! The vector of eigenvalues is assumed to be local (non-distributed) and in host memory.
      !! Moving to and from GPU memory is handled internally.
      !! @endnote
      !!
      !! @note
      !! The pika runtime is resumed when this function is called and suspended when the call terminates.
      !! @endnote
      character, intent(in) :: uplo
        !! Indicates whether the upper (`"U"`) or lower (`"L"`) triangular part of the global sub-matrix
        !! \(\mathbf{A}\) is referenced
      integer, intent(in) :: n
        !! Order of the sub-matrix \(\mathbf{A}\) used in the computation
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
        !! Local part of the global matrix \(\mathbf{A}\)
      integer, intent(in) :: ia
        !! Row index in the global matrix identifying the first row of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: ja
        !! Column index in the global matrix identifying the first column of the sub-matrix \(\mathbf{A}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: desca
        !! ScaLAPACK descriptor of the gloabl matrix \(\mathbf{A}\)
      real(kind=sp), dimension(:, :), target, intent(inout) :: b
        !! Local part of the global matrix \(\mathbf{B}\)
      integer, intent(in) :: ib
        !! Row index in the global matrix identifying the first row of the sub-matrix \(\mathbf{B}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: jb
        !! Column index in the global matrix identifying the first column of the sub-matrix \(\mathbf{B}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: descb
        !! ScaLAPACK descriptor of the gloabl matrix \(\mathbf{B}\)
      real(kind=sp), dimension(:), target, intent(out) :: w
        !! Local (non-distributed) vector of eigenvalues
      real(kind=sp), dimension(:, :), target, intent(inout) :: z
        !! Local part of the global matrix \(\mathbf{Z}\)
      integer, intent(in) :: iz
        !! Row index in the global matrix identifying the first row of the sub-matrix \(\mathbf{Z}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, intent(in) :: jz
        !! Column index in the global matrix identifying the first column of the sub-matrix \(\mathbf{Z}\)
        !! @warning
        !! Has to be `1`.
        !! @endwarning
      integer, dimension(9), intent(in) :: descz
        !! ScaLAPACK descriptor of the gloabl matrix \(\mathbf{Z}\)
      integer, target, intent(out) :: info
        !! `0` if the eigensolver completed normally

      interface
         subroutine dlaf_pssygvx_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pssygvx')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pssygvx_c
      end interface

      info = -1

      call dlaf_pssygvx_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pssygvx

   subroutine dlaf_pdsygvx(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, ib, jb, iz, jz
      integer, dimension(9), intent(in) :: desca, descb, descz
      integer, target, intent(out) :: info
      real(kind=dp), dimension(:, :), target, intent(inout) :: a, b, z
      real(kind=dp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pdsygvx_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pdsygvx')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pdsygvx_c
      end interface

      info = -1

      call dlaf_pdsygvx_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pdsygvx

   subroutine dlaf_pchegvx(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, ib, jb, iz, jz
      integer, dimension(9), intent(in) :: desca, descb, descz
      integer, target, intent(out) :: info
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a, b, z
      real(kind=sp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pchegvx_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pchegvx')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pchegvx_c
      end interface

      info = -1

      call dlaf_pchegvx_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pchegvx

   subroutine dlaf_pzhegvx(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      character, intent(in) :: uplo
      integer, intent(in) :: n, ia, ja, ib, jb, iz, jz
      integer, dimension(9), intent(in) :: desca, descb, descz
      integer, target, intent(out) :: info
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a, b, z
      real(kind=dp), dimension(:), target, intent(out) :: w

      interface
         subroutine dlaf_pzhegvx_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pzhegvx')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pzhegvx_c
      end interface

      info = -1

      call dlaf_pzhegvx_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pzhegvx

end module dlaf_fortran