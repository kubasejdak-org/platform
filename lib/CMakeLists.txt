cmake_minimum_required(VERSION 3.29)

if (NOT DEFINED PLATFORM)
    message(FATAL_ERROR "'PLATFORM' is not defined!")
endif ()

add_compile_options(-Wall -Wextra -Wpedantic -Werror $<$<COMPILE_LANGUAGE:C>:-std=c23> $<$<COMPILE_LANGUAGE:CXX>:-std=c++23> $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)

add_library(platform-main OBJECT EXCLUDE_FROM_ALL)
add_library(platform::main ALIAS platform-main)

set(PLATFORM_LIB_PATH           "${CMAKE_BINARY_DIR}/lib" CACHE INTERNAL "")
set(PLATFORM_BIN_PATH           "${CMAKE_BINARY_DIR}/bin" CACHE INTERNAL "")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PLATFORM_LIB_PATH}" PARENT_SCOPE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PLATFORM_LIB_PATH}" PARENT_SCOPE)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PLATFORM_BIN_PATH}" PARENT_SCOPE)

add_subdirectory(${PLATFORM})
add_subdirectory(info)

target_link_libraries(platform-main
    PUBLIC platform::info
)
