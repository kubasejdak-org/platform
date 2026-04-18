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

if (DEFINED BAREMETAL_ARM_TOOLCHAIN_PATH)
    file(GLOB _gcc_install_dirs LIST_DIRECTORIES true "${BAREMETAL_ARM_TOOLCHAIN_PATH}/lib/gcc/arm-none-eabi/*")
    list(GET _gcc_install_dirs 0 _gcc_install_dir)
    set(GCC_TOOLCHAIN_FLAG          "--gcc-install-dir=${_gcc_install_dir}")
endif ()

set(COMMON_FLAGS                    "-target arm-none-eabi ${GCC_TOOLCHAIN_FLAG} -fdata-sections -ffunction-sections" CACHE INTERNAL "")
set(PLATFORM_C_FLAGS                "${COMMON_FLAGS} ${APP_C_FLAGS}" CACHE INTERNAL "")
set(PLATFORM_CXX_FLAGS              "${COMMON_FLAGS} ${APP_CXX_FLAGS} -fno-exceptions" CACHE INTERNAL "")
set(CMAKE_C_FLAGS                   "${PLATFORM_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${PLATFORM_CXX_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-Os -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-Os -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(PLATFORM_EXE_LINKER_FLAGS       "" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS          "${PLATFORM_EXE_LINKER_FLAGS}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
