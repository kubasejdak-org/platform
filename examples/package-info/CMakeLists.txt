add_executable(platform-package-info
    main.cpp
)

find_package(platform COMPONENTS main package)

target_link_libraries(platform-package-info
    PRIVATE
        platform::init
        platform::main
        platform::package
)

if (NOT UNIX)
    objcopy_generate_bin(platform-package-info)
endif ()

install(TARGETS platform-package-info)
