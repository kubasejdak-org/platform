add_executable(platform-git-version
    main.cpp
)

find_package(platform COMPONENTS main)

target_link_libraries(platform-git-version
    PRIVATE platform::init platform::main
)

if (PLATFORM STREQUAL freertos-arm OR PLATFORM STREQUAL baremetal-arm)
    objcopy_generate_bin(platform-git-info)
endif ()

install(TARGETS platform-git-version)
