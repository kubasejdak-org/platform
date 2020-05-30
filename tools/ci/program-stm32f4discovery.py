#!/usr/bin/env python

# import daemon
import subprocess

# with daemon.DaemonContext():
cmd = '''openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -c "program platform-demo verify reset exit"'''
subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
