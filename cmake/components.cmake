if (toolchain IN_LIST platform_FIND_COMPONENTS)
    include(${platform_SOURCE_DIR}/lib/toolchain/setup.cmake)
endif ()

include(FetchContent)
foreach (component IN LISTS platform_FIND_COMPONENTS)
    FetchContent_Declare(platform-${component}
        SOURCE_DIR      ${platform_SOURCE_DIR}
        SOURCE_SUBDIR   lib/${component}
        SYSTEM
    )

    FetchContent_MakeAvailable(platform-${component})
endforeach ()
