add_executable(platform-paths-example
    main.cpp
)

find_package(platform COMPONENTS main)

target_link_libraries(platform-paths-example
    PRIVATE
        platform::init
        platform::main
        platform::main-paths
)

install(TARGETS platform-paths-example)
