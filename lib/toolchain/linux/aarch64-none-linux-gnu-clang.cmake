set(CMAKE_SYSTEM_NAME	            Linux)
set(CMAKE_SYSTEM_PROCESSOR          aarch64)

set(CMAKE_AR                        llvm-ar CACHE FILEPATH "")
set(CMAKE_ASM_COMPILER              clang CACHE FILEPATH "")
set(CMAKE_C_COMPILER                clang CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER              clang++ CACHE FILEPATH "")
set(CMAKE_LINKER                    lld CACHE FILEPATH "")
set(CMAKE_OBJCOPY                   llvm-objcopy CACHE FILEPATH "")
set(CMAKE_RANLIB                    llvm-ranlib CACHE FILEPATH "")
set(CMAKE_SIZE                      llvm-size CACHE FILEPATH "")
set(CMAKE_STRIP                     llvm-strip CACHE FILEPATH "")
set(CMAKE_GCOV                      llvm-cov CACHE FILEPATH "")

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(PLATFORM_C_FLAGS                "-target aarch64-none-linux-gnu --gcc-toolchain=${LINUX_ARM_TOOLCHAIN_PATH} --sysroot=${LINUX_ARM_TOOLCHAIN_PATH}/aarch64-none-linux-gnu/libc" CACHE INTERNAL "")
set(CMAKE_C_FLAGS                   "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(PLATFORM_CXX_FLAGS              "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${PLATFORM_CXX_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(PLATFORM_EXE_LINKER_FLAGS       "-fuse-ld=${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ld" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS          "${PLATFORM_EXE_LINKER_FLAGS}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

include(${CMAKE_CURRENT_LIST_DIR}/sanitizers.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)
