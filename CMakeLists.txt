cmake_minimum_required(VERSION 3.30)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

find_package(platform COMPONENTS toolchain)

project(platform ASM C CXX)

include(cmake/compilation-flags.cmake)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_subdirectory(examples)
