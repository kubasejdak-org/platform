add_executable(platform-hello-world
    main.cpp
)

find_package(platform COMPONENTS main)

target_link_libraries(platform-hello-world
    PRIVATE platform::init platform::main
)

if (PLATFORM STREQUAL freertos-arm OR PLATFORM STREQUAL baremetal-arm)
    objcopy_generate_bin(platform-hello-world)
endif ()

install(TARGETS platform-hello-world)
