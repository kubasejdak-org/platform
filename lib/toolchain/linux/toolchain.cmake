if (NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(DEFAULT_TOOLCHAIN       gcc)

    if (NOT DEFINED TOOLCHAIN)
        message(STATUS "platform: 'TOOLCHAIN' is not defined. Using '${DEFAULT_TOOLCHAIN}'.")
        set(TOOLCHAIN           ${DEFAULT_TOOLCHAIN})
    endif ()

    set(CMAKE_TOOLCHAIN_FILE    ${CMAKE_CURRENT_LIST_DIR}/${TOOLCHAIN}.cmake)
endif ()

include(${CMAKE_CURRENT_LIST_DIR}/sanitizers.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)
