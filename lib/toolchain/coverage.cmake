option(COVERAGE "Generate coverage report" OFF)

function (add_lcov_coverage)
    include(FindPackageHandleStandardArgs)
    # Find lcov.
    find_program(LCOV_BIN lcov)
    find_package_handle_standard_args(lcov REQUIRED_VARS LCOV_BIN)
    if (NOT LCOV_FOUND)
        message(FATAL_ERROR "lcov not found")
    endif ()

    # Find genhtml.
    find_program(GENHTML_BIN genhtml)
    find_package_handle_standard_args(genhtml REQUIRED_VARS GENHTML_BIN)
    if (NOT GENHTML_FOUND)
        message(FATAL_ERROR "genhtml not found")
    endif ()

    set(COVERAGE_FLAGS              --coverage)
    set(COVERAGE_OUTPUT_PATH        ${PROJECT_BINARY_DIR}/coverage)
    set(COVERAGE_IGNORE             '/usr/*' '*/.conan2/*' '*/_deps/*')
    foreach (IGNORE_PATH IN LISTS ARGN)
        list(APPEND COVERAGE_IGNORE '${IGNORE_PATH}')
    endforeach ()

    add_compile_options(${COVERAGE_FLAGS})
    set(CMAKE_C_LINK_FLAGS          "${CMAKE_C_LINK_FLAGS} ${COVERAGE_FLAGS}" CACHE INTERNAL "")
    set(CMAKE_CXX_LINK_FLAGS        "${CMAKE_CXX_LINK_FLAGS} ${COVERAGE_FLAGS}" CACHE INTERNAL "")

    if (NOT TARGET coverage)
        add_custom_target(coverage
            COMMAND ${CMAKE_COMMAND} -E make_directory ${COVERAGE_OUTPUT_PATH}
            COMMAND ${LCOV_BIN} -c -i -d . -o ${COVERAGE_OUTPUT_PATH}/coverage_base.info
            COMMAND ${LCOV_BIN} -c -d . -o ${COVERAGE_OUTPUT_PATH}/coverage.info
            COMMAND ${LCOV_BIN} -a ${COVERAGE_OUTPUT_PATH}/coverage_base.info -a ${COVERAGE_OUTPUT_PATH}/coverage.info -o ${COVERAGE_OUTPUT_PATH}/coverage.info
            COMMAND ${LCOV_BIN} -r ${COVERAGE_OUTPUT_PATH}/coverage.info ${COVERAGE_IGNORE} -o ${COVERAGE_OUTPUT_PATH}/coverage.info
        )
    endif()

    if (NOT TARGET coverage-report)
        add_custom_target(coverage-report
            COMMAND genhtml ${COVERAGE_OUTPUT_PATH}/coverage.info --output-directory ${COVERAGE_OUTPUT_PATH}/html
            DEPENDS coverage
        )
    endif()
endfunction ()

if (COVERAGE)
    add_lcov_coverage(${CMAKE_CURRENT_SOURCE_DIR}/tests/*)
endif ()
