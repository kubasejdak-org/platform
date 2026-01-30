add_executable(platform-package-info-example
    main.cpp
)

find_package(platform COMPONENTS main package)

target_link_libraries(platform-package-info-example
    PRIVATE
        platform::init
        platform::main
        platform::package
)

if (NOT UNIX)
    objcopy_generate_bin(platform-package-info-example)
endif ()

install(TARGETS platform-package-info-example)
