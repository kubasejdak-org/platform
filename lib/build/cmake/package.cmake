# platform_add_package(
#   PACKAGE_NAME    <name>        -- cmake target base name, e.g. "osal"
#   NAMESPACE       <ns>          -- C++ namespace for BuildInfo, e.g. "tr::osal"
#   [INCLUDE_PREFIX <prefix>]     -- include subdirectory (default: <alias>/package)
#   [ALIAS_NAME     <alias>]      -- cmake alias prefix (default: last namespace component)
#   [REPO_DIR       <dir>]        -- repo directory for git queries (default: CMAKE_CURRENT_SOURCE_DIR)
# )
#
# Generates a static BuildInfo class in the given namespace. Produces:
#   <PACKAGE_NAME>-package target
#   <alias>::package cmake alias
#   Public header: include/<prefix>/BuildInfo.h
#
# git tag, branch, commit are queried at every build; build date and compiler info come from the build system.

function (platform_add_package)
    cmake_parse_arguments(ARG "" "PACKAGE_NAME;NAMESPACE;INCLUDE_PREFIX;ALIAS_NAME;REPO_DIR" "" ${ARGN})

    if (NOT ARG_PACKAGE_NAME OR NOT ARG_NAMESPACE)
        message(FATAL_ERROR "platform_add_package: PACKAGE_NAME and NAMESPACE are required")
    endif ()

    if (NOT ARG_ALIAS_NAME)
        string(REGEX REPLACE ".*::" "" ARG_ALIAS_NAME "${ARG_NAMESPACE}")
    endif ()
    if (NOT ARG_INCLUDE_PREFIX)
        set(ARG_INCLUDE_PREFIX "${ARG_ALIAS_NAME}/package")
    endif ()
    if (NOT ARG_REPO_DIR)
        set(ARG_REPO_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    endif ()

    set(_tmpl   "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/templates")
    set(_script "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/getBuildInfo.cmake")
    set(_bin    "${CMAKE_CURRENT_BINARY_DIR}")

    find_package(Git REQUIRED)

    set(PACKAGE_NAMESPACE      "${ARG_NAMESPACE}")
    set(PACKAGE_INCLUDE_PREFIX "${ARG_INCLUDE_PREFIX}")
    configure_file("${_tmpl}/BuildInfo.h.in"
                   "${_bin}/include/${ARG_INCLUDE_PREFIX}/BuildInfo.h" @ONLY)
    configure_file("${_tmpl}/BuildInfo.cpp.in"
                   "${_bin}/BuildInfo.cpp" @ONLY)

    add_custom_target(${ARG_PACKAGE_NAME}-package-git
        COMMAND ${CMAKE_COMMAND}
            -D REPO_DIR=${ARG_REPO_DIR}
            -D SRC=${_tmpl}/git.h.in
            -D DST=${_bin}/git.h
            -D GIT_EXECUTABLE=${GIT_EXECUTABLE}
            -P ${_script}
        COMMENT "Updating git info for ${ARG_PACKAGE_NAME}"
    )

    add_library(${ARG_PACKAGE_NAME}-package EXCLUDE_FROM_ALL "${_bin}/BuildInfo.cpp")
    add_library(${ARG_ALIAS_NAME}::package ALIAS ${ARG_PACKAGE_NAME}-package)
    add_dependencies(${ARG_PACKAGE_NAME}-package ${ARG_PACKAGE_NAME}-package-git)

    target_include_directories(${ARG_PACKAGE_NAME}-package
        PUBLIC  "${_bin}/include"
        PRIVATE "${_bin}"
    )
endfunction ()
