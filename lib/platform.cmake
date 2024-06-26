option(PLATFORM "Platform to be used" linux)

if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${PLATFORM})
    include(${CMAKE_CURRENT_LIST_DIR}/${PLATFORM}/toolchain.cmake)
    message(STATUS "platform: Using toolchain: ${PLATFORM}/${TOOLCHAIN}")
else ()
    message(FATAL_ERROR "platform: Invalid platform name: ${PLATFORM}")
endif ()
