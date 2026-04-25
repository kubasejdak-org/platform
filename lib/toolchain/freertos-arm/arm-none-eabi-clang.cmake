set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          armv7)

# Without this flag CMake is not able to pass the compiler sanity check.
set(CMAKE_TRY_COMPILE_TARGET_TYPE   STATIC_LIBRARY)

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

set(ARM_TARGET_TRIPLE               arm-none-eabi)
set(ARM_GCC_TOOLCHAIN_ROOT          "")
set(ARM_GCC_COMPILER                "")

if (DEFINED BAREMETAL_ARM_TOOLCHAIN_PATH)
    set(ARM_GCC_TOOLCHAIN_ROOT      "${BAREMETAL_ARM_TOOLCHAIN_PATH}")
    set(ARM_GCC_COMPILER            "${BAREMETAL_ARM_TOOLCHAIN_PATH}/bin/${ARM_TARGET_TRIPLE}-gcc")
endif ()

if (NOT EXISTS "${ARM_GCC_COMPILER}")
    find_program(ARM_GCC_COMPILER NAMES ${ARM_TARGET_TRIPLE}-gcc)
endif ()

if (NOT ARM_GCC_COMPILER)
    message(FATAL_ERROR
        "platform: '${ARM_TARGET_TRIPLE}-gcc' was not found. "
        "Provide BAREMETAL_ARM_TOOLCHAIN_PATH or install ${ARM_TARGET_TRIPLE}-gcc in PATH."
    )
endif ()

if (NOT ARM_GCC_TOOLCHAIN_ROOT)
    cmake_path(GET ARM_GCC_COMPILER PARENT_PATH ARM_GCC_BIN_DIR)
    cmake_path(GET ARM_GCC_BIN_DIR PARENT_PATH ARM_GCC_TOOLCHAIN_ROOT)
endif ()

execute_process(
    COMMAND                         ${ARM_GCC_COMPILER} -print-sysroot
    OUTPUT_VARIABLE                 ARM_SYSROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

execute_process(
    COMMAND                         ${ARM_GCC_COMPILER} -print-libgcc-file-name
    OUTPUT_VARIABLE                 ARM_LIBGCC
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (ARM_LIBGCC)
    cmake_path(GET ARM_LIBGCC PARENT_PATH ARM_LIBGCC_DIR)
    cmake_path(GET ARM_LIBGCC_DIR FILENAME GCC_VERSION)
endif ()

if (ARM_SYSROOT)
    set(SYSROOT_FLAG                "--sysroot=${ARM_SYSROOT}")
endif ()

set(GCC_TOOLCHAIN_FLAG              "--gcc-toolchain=${ARM_GCC_TOOLCHAIN_ROOT}")
set(CXX_STDLIB_FLAG                 "-stdlib=libstdc++")
set(COMMON_FLAGS                    "--target=${ARM_TARGET_TRIPLE} ${GCC_TOOLCHAIN_FLAG} ${SYSROOT_FLAG} -fdata-sections -ffunction-sections" CACHE INTERNAL "")
set(PLATFORM_C_FLAGS                "${COMMON_FLAGS} ${APP_C_FLAGS}" CACHE INTERNAL "")
set(PLATFORM_CXX_FLAGS              "${COMMON_FLAGS} ${CXX_STDLIB_FLAG} ${APP_CXX_FLAGS} -fno-exceptions" CACHE INTERNAL "")
set(PLATFORM_ASM_FLAGS              "${COMMON_FLAGS} ${APP_C_FLAGS} ${APP_ASM_FLAGS}" CACHE INTERNAL "")
set(CMAKE_C_FLAGS                   "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${PLATFORM_CXX_FLAGS}" CACHE INTERNAL "")
set(CMAKE_ASM_FLAGS                 "${PLATFORM_ASM_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-Os -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-Os -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(PLATFORM_EXE_LINKER_FLAGS       "${COMMON_FLAGS} -fuse-ld=lld -Wl,--gc-sections" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS          "${PLATFORM_EXE_LINKER_FLAGS}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
