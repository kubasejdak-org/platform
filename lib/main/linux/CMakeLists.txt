target_sources(platform-main PRIVATE
    main.cpp
)

include(GNUInstallDirs)
message(STATUS "platform: Using INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "platform: Using DATAROOTDIR: ${CMAKE_INSTALL_FULL_DATAROOTDIR}")
message(STATUS "platform: Using SYSCONFDIR: ${CMAKE_INSTALL_FULL_SYSCONFDIR}")

add_library(platform-main-paths EXCLUDE_FROM_ALL
    paths.cpp
)
add_library(platform::main-paths ALIAS platform-main-paths)

target_include_directories(platform-main-paths
    PUBLIC
        include
)

target_compile_definitions(platform-main-paths
    PUBLIC
        PLATFORM_INSTALL_PREFIX_PATH="${CMAKE_INSTALL_PREFIX}"
        PLATFORM_DATAROOTDIR_PATH="${CMAKE_INSTALL_FULL_DATAROOTDIR}"    
        PLATFORM_SYSCONFDIR_PATH="${CMAKE_INSTALL_FULL_SYSCONFDIR}"    
)
