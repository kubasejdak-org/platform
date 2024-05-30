set(CMAKE_AR                        llvm-ar-18${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_ASM_COMPILER              clang-18${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_C_COMPILER                clang-18${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER              clang++-18${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_LINKER                    lld-18${CMAKE_EXECUTABLE_SUFFIX})
set(CMAKE_OBJCOPY                   llvm-objcopy-18${CMAKE_EXECUTABLE_SUFFIX} CACHE INTERNAL "")
set(CMAKE_RANLIB                    llvm-ranlib-18${CMAKE_EXECUTABLE_SUFFIX} CACHE INTERNAL "")
set(CMAKE_SIZE                      llvm-size-18${CMAKE_EXECUTABLE_SUFFIX} CACHE INTERNAL "")
set(CMAKE_STRIP                     llvm-strip-18${CMAKE_EXECUTABLE_SUFFIX} CACHE INTERNAL "")
set(CMAKE_GCOV                      llvm-cov-18${CMAKE_EXECUTABLE_SUFFIX} CACHE INTERNAL "")

set(CMAKE_C_FLAGS                   "${APP_C_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS                 "${APP_CXX_FLAGS} ${CMAKE_C_FLAGS}" CACHE INTERNAL "")

set(CMAKE_C_FLAGS_DEBUG             "-O0 -g" CACHE INTERNAL "")
set(CMAKE_C_FLAGS_RELEASE           "-O3 -DNDEBUG" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_DEBUG           "${CMAKE_C_FLAGS_DEBUG}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS_RELEASE         "${CMAKE_C_FLAGS_RELEASE}" CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)