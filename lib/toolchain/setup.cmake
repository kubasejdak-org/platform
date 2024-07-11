option(PLATFORM "Platform to be used" linux)

if (EXISTS ${CMAKE_CURRENT_LIST_DIR}/${PLATFORM})
    include(${CMAKE_CURRENT_LIST_DIR}/${PLATFORM}/toolchain.cmake)
    message(STATUS "platform: Using toolchain: ${PLATFORM}/${TOOLCHAIN}")
else ()
    message(FATAL_ERROR "platform: Invalid platform name: ${PLATFORM}")
endif ()

if (PLATFORM STREQUAL linux)
    set(OSAL_PLATFORM linux CACHE INTERNAL "")
elseif (PLATFORM STREQUAL freertos-arm)
    set(OSAL_PLATFORM freertos CACHE INTERNAL "")
else ()
    message(FATAL_ERROR "platform: Unsupported platform: ${PLATFORM}")
endif ()

message(STATUS "platform: Using OSAL platform: ${OSAL_PLATFORM}")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib" CACHE INTERNAL "")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib" CACHE INTERNAL "")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin" CACHE INTERNAL "")
