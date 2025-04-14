include(FetchContent)

FetchContent_Declare(CMSIS_5
    GIT_REPOSITORY      https://github.com/ARM-software/CMSIS_5.git
    GIT_TAG             5.9.0
    SYSTEM
)

FetchContent_Declare(cmsis_device_f4
    GIT_REPOSITORY      https://github.com/STMicroelectronics/cmsis_device_f4.git
    GIT_TAG             v2.6.10
    SYSTEM
)

FetchContent_Declare(stm32f4xx
    GIT_REPOSITORY      https://github.com/STMicroelectronics/stm32f4xx_hal_driver.git
    GIT_TAG             v1.8.3
    SYSTEM
)

FetchContent_MakeAvailable(CMSIS_5)
FetchContent_MakeAvailable(cmsis_device_f4)
FetchContent_MakeAvailable(stm32f4xx)

add_library(stm32f4xx EXCLUDE_FROM_ALL
    ${cmsis_device_f4_SOURCE_DIR}/Source/Templates/gcc/startup_stm32f407xx.s
    ${cmsis_device_f4_SOURCE_DIR}/Source/Templates/system_stm32f4xx.c
    ${stm32f4xx_SOURCE_DIR}/Src/stm32f4xx_hal.c
    ${stm32f4xx_SOURCE_DIR}/Src/stm32f4xx_hal_cortex.c
    ${stm32f4xx_SOURCE_DIR}/Src/stm32f4xx_hal_gpio.c
    ${stm32f4xx_SOURCE_DIR}/Src/stm32f4xx_hal_rcc.c
    ${stm32f4xx_SOURCE_DIR}/Src/stm32f4xx_hal_uart.c
)

target_compile_definitions(stm32f4xx
    PUBLIC
        STM32F407xx
        USE_HAL_DRIVER
)

target_include_directories(stm32f4xx
    PUBLIC
        ${cmsis_5_SOURCE_DIR}/CMSIS/Core/Include
        ${stm32f4xx_SOURCE_DIR}/Inc
        ${stm32f4xx_SOURCE_DIR}/Inc/Legacy
        ${cmsis_device_f4_SOURCE_DIR}/Include
)

target_compile_options(stm32f4xx
    PRIVATE
        -w
)
