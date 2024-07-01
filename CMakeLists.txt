cmake_minimum_required(VERSION 3.29)

list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

find_package(platform-toolchain)

project(platform ASM C CXX)

add_compile_options(-Wall -Wextra -Wpedantic -Werror "$<$<COMPILE_LANGUAGE:C>:-std=c17>" "$<$<COMPILE_LANGUAGE:CXX>:-std=c++23;-fno-exceptions>")
include(cmake/sanitizers.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_subdirectory(lib)
add_subdirectory(examples)
