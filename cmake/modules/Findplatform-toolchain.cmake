option(PLATFORM "Platform to be used" linux)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(platform-toolchain DEFAULT_MSG)

include (lib/platform.cmake)
