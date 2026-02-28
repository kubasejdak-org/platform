set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          armv7)

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_AR                        ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-ar CACHE FILEPATH "")
set(CMAKE_ASM_COMPILER              ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc CACHE FILEPATH "")
set(CMAKE_C_COMPILER                ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER              ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-g++ CACHE FILEPATH "")
set(CMAKE_LINKER                    ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-ld CACHE FILEPATH "")
set(CMAKE_OBJCOPY                   ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-objcopy CACHE FILEPATH "")
set(CMAKE_OBJDUMP                   ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-objdump CACHE FILEPATH "")
set(CMAKE_RANLIB                    ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-ranlib CACHE FILEPATH "")
set(CMAKE_SIZE                      ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-size CACHE FILEPATH "")
set(CMAKE_STRIP                     ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-strip CACHE FILEPATH "")
set(CMAKE_GCOV                      ${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcov CACHE FILEPATH "")

set(COMMON_FLAGS                    "-Wno-psabi --specs=nosys.specs -fdata-sections -ffunction-sections -Wl,--gc-sections" CACHE INTERNAL "")
set(PLATFORM_C_FLAGS                "${COMMON_FLAGS} ${APP_C_FLAGS}" CACHE INTERNAL "")
set(PLATFORM_CXX_FLAGS              "${COMMON_FLAGS} ${APP_CXX_FLAGS} -fno-exceptions" CACHE INTERNAL "")
set(CMAKE_C_FLAGS                   "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${PLATFORM_CXX_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-Os -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-Os -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
