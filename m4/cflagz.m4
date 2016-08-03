dnl Copyright 07/06/2015, 08/03/2016
dnl Aaron Caffrey https://github.com/wifiextender

dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.

dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.

dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
dnl MA 02110-1301, USA.


dnl Internal function to perform
dnl explicit compiler CFLAGS support test
AC_DEFUN([CHECK_CFLAGZ],[

  m4_foreach([tYpe], [$1], [
    AX_CHECK_COMPILE_FLAG(
      [tYpe],
      AX_APPEND_FLAG([tYpe], [CFLAGS]),
      ERR([Your compiler does not understand the above cflag])
    )

    AC_COMPILE_IFELSE([
      AC_LANG_PROGRAM([[  ]], [[ return 0; ]])
    ],[cflagz_ok=yes],[cflagz_ok=no])

    AS_IF([test "x$cflagz_ok" = "xno"], [
        ERR([Failed to compile a simple test with the above CFLAG.])
      ]
    )
  ])dnl

])

dnl Internal function to check
dnl the compiler for assembly support
AC_DEFUN([TEST_ASSEMBLY],[

  AC_MSG_CHECKING([for assembly support])

  AC_COMPILE_IFELSE([
    AC_LANG_PROGRAM([[
      #include <stdint.h>]],[[
      uintmax_t x;
      __asm__ __volatile__ (".byte 0x0f, 0x31" : "=A" (x));
    ]])
  ],[supportz_assembly=yes],[supportz_assembly=no])

  AC_MSG_RESULT([$supportz_assembly])

  AS_IF([test "x$supportz_assembly" = "xno"], [
      ERR([Your compiler does not support assembly.])
    ]
  )

])

dnl TEST_CFLAGZ() function in configure.ac
dnl
dnl Check for the presence and whether
dnl the given FLAG will work flawlessly
dnl with the currently used compiler.
dnl Will substitute each successful flag
dnl and bail out with pre-defined error msg
dnl when some FLAG is unsupported.
AC_DEFUN([TEST_CFLAGZ],[

  CHECK_CFLAGZ([
    -O2,
    -pipe,
    -std=c99,
    -Wextra,
    -Wall,
    -pedantic,
    -Wundef,
    -Wshadow,
    -w,
    -Wwrite-strings,
    -Wcast-align,
    -Wstrict-overflow=5,
    -Wconversion,
    -Wpointer-arith,
    -Wstrict-prototypes,
    -Wformat=0,
    -Wsign-compare,
    -Wdeclaration-after-statement,
    -Wendif-labels,
    -Wredundant-decls,
    -Wmissing-prototypes,
    -Wno-unused-result,
    -Wno-unused-function,
    -Wno-missing-field-initializers
  ])

  TEST_ASSEMBLY()

])
