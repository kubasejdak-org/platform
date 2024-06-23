add_executable(platform-git-version
    main.cpp
)

target_link_libraries(platform-git-version
    PRIVATE platform::init platform::main
)

if (PLATFORM STREQUAL freertos-arm OR PLATFORM STREQUAL baremetal-arm)
    objcopy_generate_bin(platform-git-info)
endif ()
