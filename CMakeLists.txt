cmake_minimum_required(VERSION 3.29)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
find_package(platform-toolchain REQUIRED)

project(platform ASM C CXX)

include(cmake/sanitizers.cmake)

add_compile_options(-Wall -Wextra -Wpedantic -Werror $<$<COMPILE_LANGUAGE:C>:-std=c23> $<$<COMPILE_LANGUAGE:CXX>:-std=c++23>)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_subdirectory(lib)
add_subdirectory(examples)
