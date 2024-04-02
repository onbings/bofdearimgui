# ==============================
# == PRESET INSTALL VARIABLES ==
# ==============================

# This include default installation directories
# based on detection performed by CMake. They
# are just default that can be overriden by the user.
include(GNUInstallDirs)

# It creates for example the following variables
#  ${CMAKE_INSTALL_BINDIR}      --> bin
#  ${CMAKE_INSTALL_LIBDIR}      --> lib, lib64, etc, ...
#  ${CMAKE_INSTALL_INCLUDEDIR}  --> include
#
# All those paths are relative to ${CMAKE_INSTALL_PREFIX} that is not
# known at configuration time and can be overriden by the user when installing.
#
# For platforms that support RPATH and ORIGIN, we can then compute the
# relative path from ${CMAKE_INSTALL_BINDIR} to ${CMAKE_INSTALL_PREFIX}
# example :
#   bin           --> some/weird/path
#   relative path --> ../../../
#
# and override RPATH with $ORIGIN/RELATIVE_PATH/${CMAKE_INSTALL_LIBDIR} at installation
#
file(RELATIVE_PATH BIN_TO_BASE_INSTALL_PATH ${CMAKE_CURRENT_LIST_DIR}/${CMAKE_INSTALL_BINDIR} ${CMAKE_CURRENT_LIST_DIR})
set (RELATIVE_PATH_BIN_TO_LIB ${BIN_TO_BASE_INSTALL_PATH}${CMAKE_INSTALL_LIBDIR})
#see also update_rpath function in update_rpath.cmake

# == SETUP BUILD DIRECTORIES ==
# Pre-stage binaries like if they were already installed
#  - CMAKE_LIBRARY_OUTPUT_DIRECTORY is for shared libraries
#  - CMAKE_ARCHIVE_OUTPUT_DIRECTORY is for static libraries
#  - CMAKE_RUNTIME_OUTPUT_DIRECTORY is for applications
set(COMPILED_BINARIES_DIR ${CMAKE_BINARY_DIR}/binaries)
set(BASE_RESOURCES_DIR    ${CMAKE_BINARY_DIR}/resources)
 
if(WIN32)
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${COMPILED_BINARIES_DIR}/bin)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${COMPILED_BINARIES_DIR}/bin)
else()
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${COMPILED_BINARIES_DIR}/lib)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${COMPILED_BINARIES_DIR}/bin)
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${COMPILED_BINARIES_DIR}/lib)

# == POPULATE PROJECTS ==
string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)

set(VCPKG_DEBUG_LIB_DIR   "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/debug/lib")
set(VCPKG_RELEASE_LIB_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/lib")

# Fix RPATH depending on build type
if("x${CMAKE_BUILD_TYPE_LOWER}x" STREQUAL "xdebugx")
  set(CMAKE_BUILD_RPATH "${VCPKG_DEBUG_LIB_DIR};${VCPKG_RELEASE_LIB_DIR}")
else()
  set(CMAKE_BUILD_RPATH "${VCPKG_RELEASE_LIB_DIR};${VCPKG_DEBUG_LIB_DIR}")
endif()

# If you plan on running your unit tests with Valgrind
# it might happen that you need to add 'suppressions'
# to silence known issues. valgrind accepts suppressions
# by taking a file (--log-file=...). The variable
# MEMORYCHECK_SUPPRESSIONS_FILE is not a CMake variable
# but can be used as a convenience to accumulate suppressions
# from all the unit tests. Consequently, if you configure
# valgrind to use that file and define this variable, you will
# have the expected result.
if(MEMORYCHECK_SUPPRESSIONS_FILE)
  file(READ   valgrind_suppression.txt           CONTENT)
  file(APPEND ${MEMORYCHECK_SUPPRESSIONS_FILE} ${CONTENT})
endif()

#foreach(Filename ${DATA_FILES})
#  message("${PROJECT_NAME_LOWER_MINUS}: Copy " ${Filename} " to " ${COMPILED_BINARIES_DIR} "/bin/data")
#  file(COPY ${Filename} DESTINATION ${COMPILED_BINARIES_DIR}/bin/data)
#endforeach() 

#install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data DESTINATION  ${COMPILED_BINARIES_DIR}/bin FILES_MATCHING PATTERN "*")
#install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data DESTINATION  ${CMAKE_INSTALL_BINDIR}      COMPONENT ${PROJECT_NAME_LOWER_MINUS}-runtime FILES_MATCHING PATTERN "*")

# == INSTALLATION ==
if(NOT APPLE)
  # Fix RPATH upon installation by replacing
  # the absolute RPATH generated by the compiler
  # by a keyword that basically says 'look for my
  # dependencies in the directory I'm currently
  # installed'.
  set_target_properties(${PROJECT_NAME_LOWER_MINUS} PROPERTIES
    INSTALL_RPATH $ORIGIN
  )

endif()

# Install the target runtime
   
install(
  TARGETS  ${PROJECT_NAME_LOWER_MINUS}
  EXPORT   ${PROJECT_NAME_LOWER_MINUS}
  RUNTIME  DESTINATION        ${CMAKE_INSTALL_BINDIR}     # For binaries and dll
           COMPONENT          ${PROJECT_NAME_LOWER_MINUS}-runtime
  LIBRARY  DESTINATION        ${CMAKE_INSTALL_LIBDIR}     # For shared libraries
           COMPONENT          ${PROJECT_NAME_LOWER_MINUS}-runtime
           NAMELINK_COMPONENT ${PROJECT_NAME_LOWER_MINUS}-devel
  ARCHIVE  DESTINATION        ${CMAKE_INSTALL_LIBDIR}     # For static libraries
           COMPONENT          ${PROJECT_NAME_LOWER_MINUS}-devel
)

# Install the public headers (don't forget the generated export directives)
install(DIRECTORY   ${CMAKE_CURRENT_SOURCE_DIR}/include/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        COMPONENT   ${PROJECT_NAME_LOWER_MINUS}-devel
)
install(FILES       ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}_export.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        COMPONENT   ${PROJECT_NAME_LOWER_MINUS}-devel OPTIONAL
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/help/html/. DESTINATION doc COMPONENT doc OPTIONAL)

# == PACKAGE INSTALLATION ==
# Export our targets
install(
  EXPORT      ${PROJECT_NAME_LOWER_MINUS}
  FILE        ${PROJECT_NAME_LOWER_MINUS}-targets.cmake
  NAMESPACE   EVS::
  DESTINATION ${CMAKE_INSTALL_DATADIR}
  COMPONENT   ${PROJECT_NAME_LOWER_MINUS}-devel
)

# Install dependencies
set(INCLUDE_REGEXES "^${CMAKE_BINARY_DIR}/vcpkg_installed/")
set(EXCLUDE_REGEXES 
  ".*[Aa][Pp][Ii]-[Mm][Ss].*"                                                         # *api-ms*
  ".*[Ee][Xx][Tt]-[Mm][Ss]-[Ww][Ii][Nn].*"                                            # *ext-ms-win*
  ".*[/\\\\][Ww][Ii][Nn][Dd][Oo][Ww][Ss][/\\\\][Ss][Yy][Ss][Tt][Ee][Mm]32[/\\\\].*"   # *\Windows\System32\*
  "^/lib"                                                                             # /lib (unix system)
  "^/usr/lib"                                                                         # /usr/lib (unix system)
) 

install(RUNTIME_DEPENDENCY_SET ${PROJECT_NAME_LOWER_MINUS}-imported-runtime-set
  PRE_INCLUDE_REGEXES    ${INCLUDE_REGEXES}
  PRE_EXCLUDE_REGEXES    ${EXCLUDE_REGEXES}
  POST_INCLUDE_REGEXES   ${INCLUDE_REGEXES}
  POST_EXCLUDE_REGEXES   ${EXCLUDE_REGEXES}
  COMPONENT              ${PROJECT_NAME_LOWER_MINUS}-runtime
)
#if (PROJECT_IS_TOP_LEVEL)  Use include_guard in cmake/cpack_main.cmake->Not working->use a variable defined in cmake/cpack_main.cmake
if (NOT CPACK_PACKAGE_NAME)
   include(cmake/cpack_main.cmake)
endif()
# Create configuration file so that find_package() from
# our dependees can find us
include(CMakePackageConfigHelpers)

set(INTERNAL_NAMESPACE EVS)

# Create and install the cmake configuration file based on our template
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}
)

unset(INTERNAL_NAMESPACE)

# Give the file a nice naming convention
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/Dependencies.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-dependencies.cmake
  COPYONLY
)

# Generate the version file and indicates compatibility strategy
write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-version.cmake
  VERSION "${PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion
)

# Install them
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-version.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER_MINUS}-dependencies.cmake
  DESTINATION ${CMAKE_INSTALL_DATADIR}
  COMPONENT   ${PROJECT_NAME_LOWER_MINUS}-devel
)

option(INSTALL_GTEST  "Disable installation of gtest" OFF)
if (PROJECT_IS_TOP_LEVEL)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E env vcpkg list --x-install-root=./vcpkg_installed
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		OUTPUT_VARIABLE DepVcpkg
	)
	file(APPEND ${CMAKE_BINARY_DIR}/DepManifest.txt "Vcpkg Dependencies for ${PROJECT_NAME}:\n")
	file(APPEND ${CMAKE_BINARY_DIR}/DepManifest.txt "${DepVcpkg}")
endif()