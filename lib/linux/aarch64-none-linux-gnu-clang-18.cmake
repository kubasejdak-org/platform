set(CMAKE_SYSTEM_NAME	            Linux)
set(CMAKE_SYSTEM_PROCESSOR          arm)

set(CMAKE_AR                        llvm-ar-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_ASM_COMPILER              clang-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_C_COMPILER                clang-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_CXX_COMPILER              clang++-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_LINKER                    lld-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_OBJCOPY                   llvm-objcopy-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_RANLIB                    llvm-ranlib-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_SIZE                      llvm-size-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_STRIP                     llvm-strip-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")
set(CMAKE_GCOV                      llvm-cov-18${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "")

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_C_FLAGS                   "-target aarch64-none-linux-gnu --gcc-toolchain=${LINUX_ARM_TOOLCHAIN_PATH} --sysroot=${LINUX_ARM_TOOLCHAIN_PATH}/aarch64-none-linux-gnu/libc" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${CMAKE_C_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG"  CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_EXE_LINKER_FLAGS          "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=${LINUX_ARM_TOOLCHAIN_PATH}/bin/aarch64-none-linux-gnu-ld")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
