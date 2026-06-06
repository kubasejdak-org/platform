cmake_minimum_required(VERSION 3.27)

include(${platform_SOURCE_DIR}/cmake/compilation-flags.cmake)

find_package(platform COMPONENTS build)

include(${platform_SOURCE_DIR}/lib/build/cmake/package.cmake)

platform_add_package(
    PACKAGE_NAME    platform
    NAMESPACE       platform
)
