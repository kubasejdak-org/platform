if (toolchain IN_LIST platform_FIND_COMPONENTS)
    include(${platform_SOURCE_DIR}/lib/toolchain/setup.cmake)
endif ()

if (main IN_LIST platform_FIND_COMPONENTS)
    FetchContent_Declare(platform-main
        SOURCE_DIR      ${platform_SOURCE_DIR}
        SOURCE_SUBDIR   lib/main
        ${SYSTEM_FLAG}
    )

    FetchContent_MakeAvailable(platform-main)
endif ()
