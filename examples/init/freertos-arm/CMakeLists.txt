target_sources(platform-init PRIVATE
    init.cpp
)

find_package(stm32f4xx)

target_include_directories(stm32f4xx
    SYSTEM PUBLIC
        .
)

target_link_libraries(platform-init
    PRIVATE
        stm32f4xx
)

target_link_options(platform-init
    PUBLIC
        -T ${CMAKE_CURRENT_SOURCE_DIR}/stm32f407vgtx.ld
)

# This target is required by the freertos-arm platform.
add_library(freertos-config INTERFACE)

target_include_directories(freertos-config
    SYSTEM INTERFACE
        .
)

target_link_libraries(freertos-config
    INTERFACE
        stm32f4xx
)
