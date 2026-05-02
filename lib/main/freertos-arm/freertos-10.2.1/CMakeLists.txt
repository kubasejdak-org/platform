add_library(freertos EXCLUDE_FROM_ALL
    croutine.c
    event_groups.c
    list.c
    queue.c
    stream_buffer.c
    tasks.c
    timers.c
)

if (FREERTOS_PORTABLE MATCHES "MPU|ARM_CM23|ARM_CM33")
    target_sources(freertos PRIVATE
        portable/Common/mpu_wrappers.c
    )
endif ()

add_subdirectory(portable)

target_include_directories(freertos
    PUBLIC
        include
    PRIVATE
        include/freertos
)

target_link_libraries(freertos
    PUBLIC
        freertos-config
        freertos-portable
)

target_compile_options(freertos
    PRIVATE
        -w
)
