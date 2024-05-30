set(CMAKE_SYSTEM_NAME	            Linux)
set(CMAKE_SYSTEM_PROCESSOR          arm)

set(CMAKE_AR                        ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ar${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_ASM_COMPILER              ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcc${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_C_COMPILER                ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcc${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER              ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-g++${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_LINKER                    ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ld${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_OBJCOPY                   ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-objcopy${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_RANLIB                    ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ranlib${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_SIZE                      ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-size${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_STRIP                     ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-strip${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_GCOV                      ${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-gcov${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_C_FLAGS                   "-Wno-psabi" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${CMAKE_C_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG"  CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
