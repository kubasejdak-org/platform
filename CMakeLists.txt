cmake_minimum_required(VERSION 3.29)

include(cmake/platform.cmake)
include(cmake/sanitizers.cmake)

project(platform ASM C CXX)

if (USE_ASAN OR USE_LSAN OR USE_UBSAN)
    enable_sanitizers()
endif ()

add_compile_options(-Wall -Wextra -Wpedantic -Werror $<$<COMPILE_LANGUAGE:C>:-std=c17> $<$<COMPILE_LANGUAGE:CXX>:-std=c++20>)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
add_subdirectory(lib)
add_subdirectory(examples)
