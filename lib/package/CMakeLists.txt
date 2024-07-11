add_library(platform-package EXCLUDE_FROM_ALL
    git.cpp
)
add_library(platform::package ALIAS platform-package)

target_include_directories(platform-package
    PUBLIC include
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}
)

find_package(Git)
add_custom_target(platform-git-info
    ${CMAKE_COMMAND} -D VERSION_TARGET=platform
    -D SRC=${CMAKE_CURRENT_SOURCE_DIR}/git.h.in
    -D DST=${CMAKE_CURRENT_BINARY_DIR}/git.h
    -D GIT_EXECUTABLE=${GIT_EXECUTABLE}
    -P ${CMAKE_CURRENT_SOURCE_DIR}/getGitInfo.cmake
)
add_dependencies(platform-package platform-git-info)
