set(CMAKE_EXPORT_COMPILE_COMMANDS OFF)

include(FetchContent)
FetchContent_Declare(stm32f4xx
    GIT_REPOSITORY      https://github.com/STMicroelectronics/stm32f4xx_hal_driver.git
    GIT_TAG             2e5e3a72bacdd58eb5f84f13ec8d6bd65e3f235d
)

FetchContent_MakeAvailable(stm32f4xx)

add_library(stm32f4xx EXCLUDE_FROM_ALL
    startup_stm32f407xx.s
    system_stm32f4xx.c
    drivers/stm32f4xx_hal.c
    drivers/stm32f4xx_hal_cortex.c
    drivers/stm32f4xx_hal_gpio.c
    drivers/stm32f4xx_hal_rcc.c
    drivers/stm32f4xx_hal_uart.c
)

target_compile_definitions(stm32f4xx
    PUBLIC USE_HAL_DRIVER STM32F407xx
)

target_include_directories(stm32f4xx
    SYSTEM PUBLIC CMSIS/core
                  CMSIS/include
                  CMSIS/device
                  drivers
                  drivers/Legacy
                  .
)

target_compile_options(stm32f4xx
    PRIVATE -w
)
