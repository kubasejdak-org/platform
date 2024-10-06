#!/bin/bash

set -e

if [[ ! -f "compile_commands.json" ]]; then
    echo "No 'compile_commands.json' file found. Aborting."
    exit 1
fi

if [[ " $@ " =~ " -fix " ]]; then
    EXTRA_ARGS="-fix"
fi

PROJECT_ROOT=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")

${PROJECT_ROOT}/tools/adjust-compilation-db.py

python3 ${PROJECT_ROOT}/tools/run-clang-tidy.py -quiet \
                                                -header-filter=${PROJECT_ROOT}'(/app/|/examples/|/lib/|/tests/).*' \
                                                -export-fixes=errors.yml \
                                                -use-color \
                                                ${EXTRA_ARGS}
