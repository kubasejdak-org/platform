option(WITH_COVERAGE "platform: Compile with coverage support" OFF)

function (add_coverage_flags)
    set(COVERAGE_FLAGS              "--coverage -fprofile-update=atomic")
    string(REPLACE " " ";" COVERAGE_FLAGS_LIST ${COVERAGE_FLAGS})
    add_compile_options(${COVERAGE_FLAGS_LIST})
    set(CMAKE_C_LINK_FLAGS          "${CMAKE_C_LINK_FLAGS} ${COVERAGE_FLAGS}" CACHE INTERNAL "")
    set(CMAKE_CXX_LINK_FLAGS        "${CMAKE_CXX_LINK_FLAGS} ${COVERAGE_FLAGS}" CACHE INTERNAL "")
endfunction ()

if (WITH_COVERAGE)
    add_coverage_flags()
endif ()
