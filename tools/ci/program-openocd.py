#!/usr/bin/python3

import shlex
import subprocess
import sys

cmd = f"openocd -f /usr/share/openocd/scripts/board/{sys.argv[1]}.cfg -c \"program {sys.argv[2]} verify reset exit\""
print(cmd)

subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE)
