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
   public :: dlaf_pssygvd, dlaf_pdsygvd, dlaf_pchegvd, dlaf_pzhegvd
   public :: dlaf_pssygvd_factorized, dlaf_pdsygvd_factorized, dlaf_pchegvd_factorized, dlaf_pzhegvd_factorized

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
      !! {!docs/snippets/note-host-matrix.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Cholesky decomposition for a distributed double-precision real symmetric positive definite matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Cholesky decomposition for a distributed single-precision complex Hermitian positive definite matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Cholesky decomposition for a distributed double-precision complex Hermitian positive definite matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Eigensolver for a distributed double-precision real symmetric matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Eigensolver for a distributed single-precision complex Hermitian matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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
      !! Eigensolver for a distributed double-precision complex Hermitian matrix \(\mathbf{A}\)
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

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

   subroutine dlaf_pssygvd(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed single-precision symmetric-definite eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pssygvd_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pssygvd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pssygvd_c
      end interface

      info = -1

      call dlaf_pssygvd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pssygvd

   subroutine dlaf_pssygvd_factorized(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed single-precision symmetric-definite eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      !! {!docs/snippets/note-factorized.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pssygvd_factorized_c( &
            uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_ &
            ) &
            bind(C, name='dlaf_pssygvd_factorized')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pssygvd_factorized_c
      end interface

      info = -1

      call dlaf_pssygvd_factorized_c(iachar(uplo, c_signed_char), n, &
                                     c_loc(a(1, 1)), ia, ja, desca, &
                                     c_loc(b(1, 1)), ib, jb, descb, &
                                     c_loc(w(1)), &
                                     c_loc(z(1, 1)), iz, jz, descz, &
                                     c_loc(info) &
                                     )

   end subroutine dlaf_pssygvd_factorized

   subroutine dlaf_pdsygvd(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed double-precision symmetric-definite eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pdsygvd_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pdsygvd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pdsygvd_c
      end interface

      info = -1

      call dlaf_pdsygvd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pdsygvd

   subroutine dlaf_pdsygvd_factorized(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed double-precision symmetric-definite eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      !! {!docs/snippets/note-factorized.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      real(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pdsygvd_factorized_c( &
            uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_ &
            ) &
            bind(C, name='dlaf_pdsygvd_factorized')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pdsygvd_factorized_c
      end interface

      info = -1

      call dlaf_pdsygvd_factorized_c(iachar(uplo, c_signed_char), n, &
                                     c_loc(a(1, 1)), ia, ja, desca, &
                                     c_loc(b(1, 1)), ib, jb, descb, &
                                     c_loc(w(1)), &
                                     c_loc(z(1, 1)), iz, jz, descz, &
                                     c_loc(info) &
                                     )

   end subroutine dlaf_pdsygvd_factorized

   subroutine dlaf_pchegvd(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed single-precision Hermitian eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pchegvd_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pchegvd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pchegvd_c
      end interface

      info = -1

      call dlaf_pchegvd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pchegvd

   subroutine dlaf_pchegvd_factorized(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed single-precision Hermitian eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      !! {!docs/snippets/note-factorized.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=sp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=sp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pchegvd_factorized_c( &
            uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_ &
            ) &
            bind(C, name='dlaf_pchegvd_factorized')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pchegvd_factorized_c
      end interface

      info = -1

      call dlaf_pchegvd_factorized_c(iachar(uplo, c_signed_char), n, &
                                     c_loc(a(1, 1)), ia, ja, desca, &
                                     c_loc(b(1, 1)), ib, jb, descb, &
                                     c_loc(w(1)), &
                                     c_loc(z(1, 1)), iz, jz, descz, &
                                     c_loc(info) &
                                     )

   end subroutine dlaf_pchegvd_factorized

   subroutine dlaf_pzhegvd(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed double-precision Hermitian eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pzhegvd_c(uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_) &
            bind(C, name='dlaf_pzhegvd')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pzhegvd_c
      end interface

      info = -1

      call dlaf_pzhegvd_c(iachar(uplo, c_signed_char), n, &
                          c_loc(a(1, 1)), ia, ja, desca, &
                          c_loc(b(1, 1)), ib, jb, descb, &
                          c_loc(w(1)), &
                          c_loc(z(1, 1)), iz, jz, descz, &
                          c_loc(info) &
                          )

   end subroutine dlaf_pzhegvd

   subroutine dlaf_pzhegvd_factorized(uplo, n, a, ia, ja, desca, b, ib, jb, descb, w, z, iz, jz, descz, info)
      !! Generalized eigensolver for a distributed double-precision Hermitian eigenproblem of the form
      !! \[\mathbf{A}\mathbf{x} = \lambda\mathbf{B}\mathbf{x}\]
      !! {!docs/snippets/note-host-matrix.md!}
      !! {!docs/snippets/note-local-evals.md!}
      !! {!docs/snippets/note-pika.md!}
      !! {!docs/snippets/note-factorized.md!}
      character, intent(in) :: uplo
      !! {!docs/snippets/uplo-w-note.md!}
      integer, intent(in) :: n
      !! {!docs/snippets/n.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: a
      !! {!docs/snippets/a.md!}
      integer, intent(in) :: ia
      !! {!docs/snippets/ia.md!}
      integer, intent(in) :: ja
      !! {!docs/snippets/ja.md!}
      integer, dimension(9), intent(in) :: desca
      !! {!docs/snippets/desca.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: b
      !! {!docs/snippets/b.md!}
      integer, intent(in) :: ib
      !! {!docs/snippets/ib.md!}
      integer, intent(in) :: jb
      !! {!docs/snippets/jb.md!}
      integer, dimension(9), intent(in) :: descb
      !! {!docs/snippets/descb.md!}
      real(kind=dp), dimension(:), target, intent(out) :: w
      !! {!docs/snippets/w.md!}
      complex(kind=dp), dimension(:, :), target, intent(inout) :: z
      !! {!docs/snippets/z.md!}
      integer, intent(in) :: iz
      !! {!docs/snippets/iz.md!}
      integer, intent(in) :: jz
      !! {!docs/snippets/jz.md!}
      integer, dimension(9), intent(in) :: descz
      !! {!docs/snippets/descz.md!}
      integer, target, intent(out) :: info
      !! {!docs/snippets/info.md!}

      interface
         subroutine dlaf_pzhegvd_factorized_c( &
            uplo_, n_, a_, ia_, ja_, desca_, b_, ib_, jb_, descb_, w_, z_, iz_, jz_, descz_, info_ &
            ) &
            bind(C, name='dlaf_pzhegvd_factorized')

            import :: c_int, c_ptr, c_signed_char

            integer(kind=c_signed_char), value :: uplo_
            integer(kind=c_int), value :: n_, ia_, ja_, ib_, jb_, iz_, jz_
            type(c_ptr), value :: a_, b_, w_, z_
            integer(kind=c_int), dimension(9) :: desca_, descb_, descz_
            type(c_ptr), value :: info_
         end subroutine dlaf_pzhegvd_factorized_c
      end interface

      info = -1

      call dlaf_pzhegvd_factorized_c(iachar(uplo, c_signed_char), n, &
                                     c_loc(a(1, 1)), ia, ja, desca, &
                                     c_loc(b(1, 1)), ib, jb, descb, &
                                     c_loc(w(1)), &
                                     c_loc(z(1, 1)), iz, jz, descz, &
                                     c_loc(info) &
                                     )

   end subroutine dlaf_pzhegvd_factorized

end module dlaf_fortran
