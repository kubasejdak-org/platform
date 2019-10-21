set(CMAKE_SYSTEM_NAME           Linux)

if (WIN32)
    set(EXE_EXTENSION           ".exe")
else ()
    set(EXE_EXTENSION           "")
endif ()

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_AR                    gcc-ar-7${EXE_EXTENSION})
set(CMAKE_ASM_COMPILER          gcc-7${EXE_EXTENSION})
set(CMAKE_C_COMPILER            gcc-7${EXE_EXTENSION})
set(CMAKE_CXX_COMPILER          g++-7${EXE_EXTENSION})
set(CMAKE_OBJCOPY               objcopy${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_RANLIB                ranlib${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_SIZE_UTIL             size${EXE_EXTENSION} CACHE INTERNAL "")
set(CMAKE_STRIP                 strip${EXE_EXTENSION} CACHE INTERNAL "")

set(CMAKE_C_FLAGS               "" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS             "${CMAKE_C_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG         "-g -O0" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE       "-O3" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG       "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE     "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
