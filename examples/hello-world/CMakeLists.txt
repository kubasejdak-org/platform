add_executable(platform-hello-world-example
    main.cpp
)

find_package(platform COMPONENTS main)

target_link_libraries(platform-hello-world-example
    PRIVATE
        platform::init
        platform::main
)

if (NOT UNIX)
    objcopy_generate_bin(platform-hello-world-example)
endif ()

install(TARGETS platform-hello-world-example)
