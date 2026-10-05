cmake_minimum_required(VERSION 3.19)

project(aigefs_ensstat LANGUAGES Fortran)

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

if(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -traceback -convert big_endian")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -check all -ftrapuv")
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fbacktrace -fconvert=big-endian")
  set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
  set(CMAKE_Fortran_FLAGS_DEBUG "-O0 -g -fcheck=all -ffpe-trap=invalid,zero,overflow")
endif()

find_package(bacio REQUIRED)
find_package(w3emc REQUIRED)
find_package(g2 REQUIRED)

list(APPEND fortran_src
  ensstat.f90
  init_parm.f90
  printinfr.f90
  isrchne.f90
  EPDF.f
  SORTMM.f
)

set(exe_name aigefs_ensstat)
add_executable(${exe_name} ${fortran_src})
target_link_libraries(${exe_name} PRIVATE bacio::bacio_4
                                          w3emc::w3emc_4
                                          g2::g2_4)

install(TARGETS ${exe_name} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
