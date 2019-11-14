set(CMAKE_SYSTEM_NAME               Linux)
set(CMAKE_SYSTEM_PROCESSOR          ARM)

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

set(CMAKE_AR                        llvm-ar-9${EXE_EXTENSION})
set(CMAKE_ASM_COMPILER              clang-9${EXE_EXTENSION})
set(CMAKE_C_COMPILER                clang-9${EXE_EXTENSION})
set(CMAKE_CXX_COMPILER              clang++-9${EXE_EXTENSION})
set(CMAKE_OBJCOPY                   llvm-objcopy-9${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_RANLIB                    llvm-ranlib-9${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_SIZE_UTIL                 llvm-size-9${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_STRIP                     llvm-strip-9${EXE_EXTENSION} CACHE INTERNAL "")

set(CMAKE_C_FLAGS                   "${APP_C_FLAGS} -target arm-linux-gnueabihf --gcc-toolchain=${LINUX_ARM_TOOLCHAIN_PATH} --sysroot=${LINUX_ARM_TOOLCHAIN_PATH}/arm-linux-gnueabihf/libc" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${APP_CXX_FLAGS} ${CMAKE_C_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-g -O0" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_EXE_LINKER_FLAGS          "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=${LINUX_ARM_TOOLCHAIN_PATH}/bin/arm-linux-gnueabihf-ld")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)