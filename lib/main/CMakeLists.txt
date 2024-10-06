cmake_minimum_required(VERSION 3.30)

include(${platform_SOURCE_DIR}/cmake/compilation-flags.cmake)

add_library(platform-main OBJECT EXCLUDE_FROM_ALL)
add_library(platform::main ALIAS platform-main)

target_include_directories(platform-main
    PUBLIC
        include
)

add_subdirectory(${PLATFORM})
