#!/usr/bin/env python3

import json

COMPILATION_DB_FILE = "compile_commands.json"

PATTERNS_TO_REMOVE = [
    "_deps"
]

with open(COMPILATION_DB_FILE) as file:
    compilation_db = json.load(file)

    for translation_unit in compilation_db[:]:
        if any(pattern in translation_unit["file"] for pattern in PATTERNS_TO_REMOVE):
            print(f"Removing {translation_unit['file']} from {COMPILATION_DB_FILE}")
            compilation_db.remove(translation_unit)

with open(COMPILATION_DB_FILE, "w") as file:
    json.dump(compilation_db, file, indent=2)
