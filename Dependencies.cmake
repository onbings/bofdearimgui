include(CMakeFindDependencyMacro)

macro(find_package_dependency)
  # When loading the *Config.cmake we should
  # call find_dependency which is just a wrapper
  # around find_package to display better
  # messages to the user. When directly dealing
  # with our CMakeLists.txt, we should call
  # find_package directly
  if(FROM_CONFIG_FILE)
     find_dependency(${ARGN})
  else()
     find_package(${ARGN})
  endif()
endmacro()

# == OPTIONAL DEPENDENCIES ==

# == REQUIRED DEPENDENCIES ==
find_package(GTest CONFIG REQUIRED)
find_package(bofstd CONFIG REQUIRED)
find_package(SDL2 CONFIG REQUIRED)
find_package(hello-imgui CONFIG REQUIRED)
#NO find_package(implot CONFIG REQUIRED)
#if find_package, add   {"name": "hello-imgui", "features": [ "opengl3-binding", "sdl2-binding"] } to vcpkg.json
if (EMSCRIPTEN)
else()
endif()