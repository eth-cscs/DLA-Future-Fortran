!
! Distributed Linear Algebra with Future (DLAF)
!
! Copyright (c) 2018-2024, ETH Zurich
! All rights reserved.
!
! Please, refer to the LICENSE file in the root directory.
! SPDX-License-Identifier: BSD-3-Clause
!

#:set precision = ['sp', 'dp']
#:set types = ['real', 'complex']
#:set symbols = {('sp', 'real'): 's', ('sp', 'complex'): 'c', ('dp', 'real'): 'd', ('dp', 'complex'): 'z'}
module testutils

#ifdef __MPI_F08
   use mpi_f08
#else
   use mpi
#endif

   use iso_fortran_env, only: sp => real32, dp => real64, error_unit

   implicit none
   private

   public :: allclose
   public :: terminate
   public :: setup_mpi, teardown_mpi
   public :: bcast_check
   public :: set_random_matrix, init_desc

   interface allclose
      #:for dtype in precision
         #:for type in types
            #:for array in ['mat', 'vec']
               #:set symbol = symbols[(dtype, type)]
               module procedure allclose_${symbol}$_${array}$
            #:endfor
         #:endfor
      #:endfor
   end interface allclose

   interface close
      #:for dtype in precision
         #:for type in types
            #:set symbol = symbols[(dtype, type)]
            module procedure close_${symbol}$
         #:endfor
      #:endfor
   end interface close

   interface set_random_matrix
      #:for dtype in precision
         #:for type in types
            #:set symbol = symbols[(dtype, type)]
            module procedure set_random_matrix_${symbol}$
         #:endfor
      #:endfor
   end interface set_random_matrix

contains

   #:for dtype in precision
      #:for type in types
         #:set symbol = symbols[(dtype, type)]
         function allclose_${symbol}$_mat(x, y, rtol, atol, uplo) result(aclose)
            ${type}$ (kind=${dtype}$), intent(in), dimension(:, :) :: x, y
            real(kind=${dtype}$), intent(in), optional :: rtol, atol
            character, intent(in), optional :: uplo
            logical :: aclose

            real(kind=${dtype}$) :: rtol_l, atol_l
            integer :: m, n, i, j

            if (present(rtol)) then
               rtol_l = rtol
            else
               ! NumPy default
               rtol_l = 1.0e-5_${dtype}$
            end if

            if (present(atol)) then
               atol_l = atol
            else
               ! NumPy default
               atol_l = 1.0e-8_${dtype}$
            end if

            aclose = .true.

            if (size(x, 1) /= size(y, 1) .or. size(x, 2) /= size(y, 2)) then
               aclose = .false.
               return
            end if

            m = size(x, 1)
            n = size(x, 2)

            if (present(uplo)) then
               if (uplo .eq. 'L') then
                  do i = 1, m
                     do j = 1, i
                        if (.not. close (x(i, j), y(i, j), rtol_l, atol_l)) then
                           aclose = .false.
                           write (error_unit, *) i, j, x(i, j), y(i, j)
                           return
                        end if
                     end do
                  end do
               else
                  do i = 1, m
                     do j = i + 1, n
                        if (.not. close (x(i, j), y(i, j), rtol_l, atol_l)) then
                           aclose = .false.
                           return
                        end if
                     end do
                  end do
               end if
            else
               do j = 1, n
                  do i = 1, m
                     if (.not. close (x(i, j), y(i, j), rtol_l, atol_l)) then
                        aclose = .false.
                        return
                     end if
                  end do
               end do
            end if

            return
         end function allclose_${symbol}$_mat
      #:endfor
   #:endfor

   #:for dtype in precision
      #:for type in types
         #:set symbol = symbols[(dtype, type)]
         pure function allclose_${symbol}$_vec(x, y, rtol, atol) result(aclose)
            ${type}$ (kind=${dtype}$), intent(in), dimension(:) :: x, y
            real(kind=${dtype}$), intent(in), optional :: rtol, atol
            logical :: aclose

            real(kind=${dtype}$) :: rtol_l, atol_l
            integer :: n

            if (present(rtol)) then
               rtol_l = rtol
            else
               ! NumPy default
               rtol_l = 1.0e-5_${dtype}$
            end if

            if (present(atol)) then
               atol_l = atol
            else
               ! NumPy default
               atol_l = 1.0e-8_${dtype}$
            end if

            aclose = .true.

            if (size(x) /= size(y)) then
               aclose = .false.
               return
            end if

            n = size(x)

            aclose = all(close (x, y, rtol_l, atol_l))

            return
         end function allclose_${symbol}$_vec
      #:endfor
   #:endfor

   #:for dtype in precision
      #:for type in types
         #:set symbol = symbols[(dtype, type)]
         elemental pure function close_${symbol}$ (x, y, rtol, atol) result(is_close)
            ${type}$ (kind=${dtype}$), intent(in) :: x, y
            real(kind=${dtype}$), intent(in) :: rtol, atol
            logical :: is_close

            is_close = .true.

            if (abs(x - y) > atol + rtol*abs(y)) then
               is_close = .false.
            end if

            return
         end function close_${symbol}$
      #:endfor
   #:endfor

   subroutine terminate(ictxt)
      integer, intent(in), optional :: ictxt
      integer :: ierr

      if (present(ictxt)) call blacs_gridexit(ictxt)
      call mpi_finalize(ierr)
      stop - 1
   end subroutine terminate

   subroutine setup_mpi(nprow, npcol, rank, nprocs)
      integer, intent(in) :: nprow, npcol
      integer, intent(out) :: rank, nprocs
      integer:: ierr, threading_provided

      call mpi_init_thread(MPI_THREAD_MULTIPLE, threading_provided, ierr)

      if (threading_provided /= MPI_THREAD_MULTIPLE) then
         write (error_unit, *) 'ERROR: The MPI library does not support MPI_THREAD_MULTIPLE'
         call terminate()
      end if

      call mpi_comm_rank(MPI_COMM_WORLD, rank, ierr)
      call mpi_comm_size(MPI_COMM_WORLD, nprocs, ierr)

      if (nprocs /= nprow*npcol) then
         if (rank == 0) then
            write (error_unit, *) 'ERROR: The test suite needs to run with exactly ', nprow*npcol, ' processes'
            write (error_unit, *) 'ERROR: Got ', nprocs, ' processes'
         end if
         call terminate()
      end if
   end subroutine setup_mpi

   subroutine teardown_mpi()
      integer:: ierr

      call mpi_finalize(ierr)

   end subroutine teardown_mpi

   subroutine bcast_check(result)
      logical, intent(inout) :: result
      integer:: ierr

      call mpi_bcast(result, 1, MPI_C_BOOL, 0, MPI_COMM_WORLD, ierr)

   end subroutine bcast_check

   #:for dtype in precision
      #:set type = "real"
      #:set symbol = symbols[(dtype, type)]
      subroutine set_random_matrix_${symbol}$ (a, s)

         real(kind=${dtype}$), dimension(:, :), intent(out) :: a

         integer :: n, i

         integer, allocatable:: seed(:)
         integer :: nseed
         integer, intent(in), optional :: s

         call random_seed(size=nseed)
         allocate (seed(nseed))
         if (present(s)) then
            seed(:) = s
         else
            seed(:) = 0
         end if
         call random_seed(put=seed)
         deallocate (seed)

         if (size(a, 1) /= size(a, 2)) then
            write (error_unit, *) 'ERROR: Matrix must be square'
            call terminate()
         end if

         n = size(a, 1)

         call random_number(a)

         ! Make symmetric
         A = 0.5_${dtype}$*(a + transpose(a))

         ! Make positive definite
         do i = 1, n
            A(i, i) = A(i, i) + n
         end do

      end subroutine set_random_matrix_${symbol}$
   #:endfor

   #:for dtype in precision
      #:set type = "complex"
      #:set symbol = symbols[(dtype, type)]
      subroutine set_random_matrix_${symbol}$ (a, s)

         complex(kind=${dtype}$), dimension(:, :), intent(out) :: a

         real(kind=${dtype}$), dimension(:, :), allocatable :: rand
         integer :: n, i

         integer, allocatable:: seed(:)
         integer :: nseed
         integer, intent(in), optional :: s

         call random_seed(size=nseed)
         allocate (seed(nseed))
         if (present(s)) then
            seed(:) = s
         else
            seed(:) = 0
         end if
         call random_seed(put=seed)
         deallocate (seed)

         if (size(a, 1) /= size(a, 2)) then
            write (error_unit, *) 'ERROR: Matrix must be square'
            call terminate()
         end if

         n = size(a, 1)

         allocate (rand(n, n))

         call random_number(rand)
         a%re = rand

         call random_number(rand)
         a%im = rand

         deallocate (rand)

         ! Make hermitian
         a = a*conjg(transpose(a))

         ! Make positive definite
         do i = 1, n
            a(i, i) = a(i, i) + n
         end do

      end subroutine set_random_matrix_${symbol}$
   #:endfor

   subroutine init_desc(desc)
      integer, intent(out), dimension(9) :: desc

      desc(:) = 0
      desc(2) = -1
   end subroutine init_desc

end module testutils
