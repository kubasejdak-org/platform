# cmake -P script invoked at build time by the <package>-package-git custom target.
#
# Required inputs (via -D):
#   REPO_DIR       -- source directory within the repo to query (git walks up to find .git)
#   SRC            -- path to git_info.h.in template
#   DST            -- output path for git_info.h
#   GIT_EXECUTABLE -- path to git binary

macro (check_git_tag)
    if (GIT_EXECUTABLE)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} describe --tags --dirty --broken --always
            WORKING_DIRECTORY   ${REPO_DIR}
            OUTPUT_VARIABLE     GIT_TAG
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (GIT_ERROR OR NOT DEFINED GIT_TAG)
        set(GIT_TAG "N/A")
    endif ()
endmacro ()

macro (check_git_branch)
    if (GIT_EXECUTABLE)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY   ${REPO_DIR}
            OUTPUT_VARIABLE     GIT_BRANCH
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (GIT_ERROR OR NOT DEFINED GIT_BRANCH)
        set(GIT_BRANCH "N/A")
    endif ()
endmacro ()

macro (check_git_commit)
    if (GIT_EXECUTABLE)
        execute_process(
            COMMAND             ${GIT_EXECUTABLE} rev-parse HEAD
            WORKING_DIRECTORY   ${REPO_DIR}
            OUTPUT_VARIABLE     GIT_COMMIT
            RESULT_VARIABLE     GIT_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif ()

    if (GIT_ERROR OR NOT DEFINED GIT_COMMIT)
        set(GIT_COMMIT "N/A")
    endif ()
endmacro ()

check_git_tag()
check_git_branch()
check_git_commit()
string(TIMESTAMP BUILD_DATE "%Y.%m.%d %H:%M")

configure_file(${SRC} ${DST} @ONLY)
