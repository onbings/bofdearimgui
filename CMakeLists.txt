#
# Copyright (c) 2024,2044 OnBings. All rights reserved.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
# PURPOSE.
#
# History:		1 Jan 2024: BHA: Initial version 
# 

#git clone git@github.com:onbings/bofdearimgui.git

#Emscripten build
#cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_INSTALL_PREFIX=C:/bld/evs-hwfw-xts-web/binaries -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=C:/pro/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_TOOLCHAIN_FILE=C:/pro/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=wasm32-emscripten -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -SC:/pro/evs-hwfw-xts/bofdearimgui -BC:/bld/bofdearimgui-web -DCMAKE_CROSSCOMPILING_EMULATOR=C:/pro/emsdk/node/16.20.0_64bit/bin/node.exe -G Ninja
#cd C:\pro\evs-hwfw-xts\bofdearimgui\vcprj
#vcprj.bat Web
#Launch VsCode
#CTRL-ALT-TARGET
#Select VcRun::WebNode::ut_bofdearimgui in debug icon

#Windows build
#cmake -DCMAKE_INSTALL_PREFIX=C:/bld/github-win/binaries -DCMAKE_TOOLCHAIN_FILE=C:/pro/vcpkg/scripts/buildsystems/vcpkg.cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug -SC:/pro/github/bofdearimgui -BC:/bld/bofdearimgui-win

#Linux build
#cmake -DCMAKE_INSTALL_PREFIX=/home/bha/bld/github-win/binaries -DCMAKE_TOOLCHAIN_FILE=/home/bha/pro/vcpkg/scripts/buildsystems/vcpkg.cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Debug  -DRHEL:STRING="el9" -S/home/bha/pro/github/bofdearimgui -B/home/bha/bld/bofdearimgui-lin

#cmake --build . -- -j 40
#cmake --install . --config Debug

cmake_minimum_required(VERSION 3.28)

# Paranoid check : in-source generation is forbidden
if("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
  message(FATAL_ERROR "You cannot generate your binary solution into your source directory !")
endif()
 
include(cmake/fixup_vs_crt.cmake)
include(cmake/vcpkg_install.cmake)
include(cmake/fetch_content.cmake)

project(bofdearimgui VERSION 2.2.1.11)
include(cmake/compile.cmake)
include(Dependencies.cmake)

option(${PROJECT_NAME_UPPER_UNDERSCORE}_BUILD_TESTS       "Build units tests of ${PROJECT_NAME_LOWER} project"                                  OFF)
option(${PROJECT_NAME_UPPER_UNDERSCORE}_ENABLE_VERSIONING "Enable library versioning naming scheme for ${PROJECT_NAME_LOWER} libraries"         ON)
option(${PROJECT_NAME_UPPER_UNDERSCORE}_FORCE_EXPORT_ALL  "Force exporting all symbols of ${PROJECT_NAME_LOWER} libraries (for shared library)" OFF)
set(${PROJECT_NAME_UPPER_UNDERSCORE}_EMSCRIPTEN_WASM_EXCEPTION OFF)  #hello-imgui use exception

#got by git clone https://github.com/pthom/hello_imgui.git
#add_subdirectory(hello_imgui)

set(IMGUI_FILES
  ./src/bof_dearimgui.cpp
   ./include/bofdearimgui/bof_dearimgui.h
   ./src/bof_dearimgui_internal.cpp
   ./include/bofdearimgui/bof_dearimgui_internal.h
)
set(IMGUI_IMNODE_FILES
   ./include/bofdearimgui/bof_dearimgui_imnodes.h 
   ./include/bofdearimgui/bof_dearimgui_imnodes_internal.h 
   ./src/bof_dearimgui_imnodes.cpp
)
set(IMGUI_TOGGLE_FILES
	./include/bofdearimgui/imgui_toggle/imgui_toggle_math.h
	./include/bofdearimgui/imgui_toggle/imgui_offset_rect.h
	./include/bofdearimgui/imgui_toggle/imgui_toggle.h
	./src/imgui_toggle/imgui_toggle.cpp
	./include/bofdearimgui/imgui_toggle/imgui_toggle_palette.h
	./src/imgui_toggle/imgui_toggle_palette.cpp
	./include/bofdearimgui/imgui_toggle/imgui_toggle_presets.h
	./src/imgui_toggle/imgui_toggle_presets.cpp
	./include/bofdearimgui/imgui_toggle/imgui_toggle_renderer.h
	./src/imgui_toggle/imgui_toggle_renderer.cpp
)
set(IMGUI_KNOB_FILES
	./include/bofdearimgui/imgui-knobs/imgui-knobs.h
	./src/imgui-knobs/imgui-knobs.cpp
)
# == BUILD ==
add_library(${PROJECT_NAME_LOWER_MINUS}
   ${IMGUI_FILES}
   ${IMGUI_IMNODE_FILES}
   ${IMGUI_TOGGLE_FILES}
   ${IMGUI_KNOB_FILES}
)

source_group("ImGui"		 FILES ${IMGUI_FILES})
source_group("ImNode"		 FILES ${IMGUI_IMNODE_FILES})
source_group("ImToggle"		 FILES ${IMGUI_TOGGLE_FILES})
source_group("ImKnob"		 FILES ${IMGUI_KNOB_FILES})

# Alias with the namespaced version (consistency)
add_library(ONBINGS::${PROJECT_NAME_LOWER_MINUS} ALIAS ${PROJECT_NAME_LOWER_MINUS})

include(cmake/dearimgui.cmake)

target_compile_definitions(${PROJECT_NAME_LOWER_MINUS}
  PRIVATE
    -D${PROJECT_NAME_UPPER_UNDERSCORE}_EXPORTS=1	#in lower case to define the symbol BOFDEARIMGUI_EXPORT (upper case) in bofdearimgui_export.h
)

if (EMSCRIPTEN)
  include(cmake/emscripten.cmake)
else()
  target_link_libraries(${PROJECT_NAME_LOWER_MINUS} 
    PRIVATE
  )
endif()

target_include_directories(${PROJECT_NAME_LOWER_MINUS}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/hello_imgui/external/imgui> #imgui
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/hello_imgui/src> #hello_imgui

    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/bofdearimgui/imgui_toggle> 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/bofdearimgui/imgui-knobs> 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>       #for flat model (.h and .cpp in source dir)
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>		#for bofdearimgui_export.h install (below) 
)
target_link_libraries(${PROJECT_NAME_LOWER_MINUS}
  PRIVATE
    ONBINGS::bofstd
    $<TARGET_NAME_IF_EXISTS:SDL2::SDL2main>
    $<IF:$<TARGET_EXISTS:SDL2::SDL2>,SDL2::SDL2,SDL2::SDL2-static>	
  PUBLIC
	hello-imgui::hello_imgui
    implot::implot
)

if(${PROJECT_NAME_UPPER_UNDERSCORE}_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()

# To avoid problem with EMSCRIPTEN compilation we only get third party libs which dont 
# depend on pthread lib. These one are get using the fetch_vcpkg_library function as
# they must be built with a strict control of options which is not possible with vcpkg 
# build in manifest mode 
if (PROJECT_IS_TOP_LEVEL)
#	message("==========================Start fetch for ${PROJECT_NAME}=========================")
#	fetch_external_component_add(googletest "${LIST_OF_COMPONENT}" https://github.com/google/googletest release-1.12.1)
#	make_external_component_available("${LIST_OF_COMPONENT}")
#	message("==========================End fetch for ${PROJECT_NAME}===========================")
#	set_target_properties(gtest PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#	set_target_properties(gtest_main PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()
include(cmake/export_version.cmake)
include(cmake/install.cmake)

#get_cmake_property(_variableNames VARIABLES)
#foreach(_variableName ${_variableNames})
#    message(STATUS "CMake variable: ${_variableName}=${${_variableName}}")
#endforeach()