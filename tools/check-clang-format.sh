#!/bin/bash

set -e

python3 tools/run-clang-format.py -r --color always -i .
