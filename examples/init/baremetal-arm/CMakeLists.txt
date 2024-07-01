target_sources(platform-init PRIVATE
    init.cpp
)

find_package(stm32f4xx)

target_include_directories(stm32f4xx
    PUBLIC .
)

target_link_libraries(platform-init
    PRIVATE stm32f4xx
)

target_link_options(platform-init
    PUBLIC -T ${CMAKE_CURRENT_SOURCE_DIR}/stm32f407vgtx.ld
)
