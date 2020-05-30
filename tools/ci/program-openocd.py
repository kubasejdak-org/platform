#!/usr/bin/python3

# import daemon
import subprocess
import sys

# with daemon.DaemonContext():
cmd = '''openocd -f /usr/share/openocd/scripts/board/{}.cfg -c "program {} verify reset exit"'''.format(sys.argv[1], sys.argv[2])
subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
