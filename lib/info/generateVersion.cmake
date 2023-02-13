string(TOUPPER ${VERSION_TARGET} VERSION_TARGET)

macro(check_git_branch)
    if (GIT_EXECUTABLE)
        get_filename_component(SRC_DIR ${SRC} DIRECTORY)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY   ${SRC_DIR}
            OUTPUT_VARIABLE     GIT_BRANCH
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (NOT DEFINED GIT_BRANCH)
        set(GIT_BRANCH "N/A")
    endif ()
endmacro()

macro(check_git_commit)
    if (GIT_EXECUTABLE)
        get_filename_component(SRC_DIR ${SRC} DIRECTORY)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} rev-parse HEAD
            WORKING_DIRECTORY   ${SRC_DIR}
            OUTPUT_VARIABLE     GIT_COMMIT
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (NOT DEFINED GIT_COMMIT)
        set(GIT_COMMIT "N/A")
    endif ()
endmacro()

macro(check_git_tag)
    if (GIT_EXECUTABLE)
        get_filename_component(SRC_DIR ${SRC} DIRECTORY)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} describe --tags --dirty --broken --always
            WORKING_DIRECTORY   ${SRC_DIR}
            OUTPUT_VARIABLE     GIT_TAG
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (NOT DEFINED GIT_TAG)
        set(GIT_TAG "N/A")
    endif ()
endmacro()

check_git_branch()
check_git_commit()
check_git_tag()

configure_file(${SRC} ${DST} @ONLY)
