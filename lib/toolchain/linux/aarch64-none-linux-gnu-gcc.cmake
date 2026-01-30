set(CMAKE_SYSTEM_NAME	            Linux)
set(CMAKE_SYSTEM_PROCESSOR          aarch64)

set(CMAKE_AR                        ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ar CACHE FILEPATH "")
set(CMAKE_ASM_COMPILER              ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcc CACHE FILEPATH "")
set(CMAKE_C_COMPILER                ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcc CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER              ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-g++ CACHE FILEPATH "")
set(CMAKE_LINKER                    ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ld CACHE FILEPATH "")
set(CMAKE_OBJCOPY                   ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-objcopy CACHE FILEPATH "")
set(CMAKE_RANLIB                    ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ranlib CACHE FILEPATH "")
set(CMAKE_SIZE                      ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-size CACHE FILEPATH "")
set(CMAKE_STRIP                     ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-strip CACHE FILEPATH "")
set(CMAKE_GCOV                      ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcov CACHE FILEPATH "")

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(PLATFORM_C_FLAGS                "-Wno-psabi" CACHE INTERNAL "")
set(PLATFORM_CXX_FLAGS              "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_C_FLAGS                   "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${PLATFORM_CXX_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(PLATFORM_EXE_LINKER_FLAGS       "" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS          "${PLATFORM_EXE_LINKER_FLAGS}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
