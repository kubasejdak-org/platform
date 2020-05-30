#!/usr/bin/python3

import serial
import sys

class UartLogs:
    def __init__(self, device, baudrate):
        self.uart = serial.Serial(device, baudrate, timeout=30)
        self.uart.reset_input_buffer()
        self.uart.reset_output_buffer()

    def run(self):
        print("Running UART logs reader on {} with speed {}".format(self.uart.port, self.uart.baudrate))

        while True:
            line = self.uart.readline().rstrip()
            if not line:
                print("Timeout")
                return 1

            print(line)
            if line == "PASSED":
                return 0

            return 1

server = UartLogs("/dev/serial0", 115200)
code = server.run()
sys.exit(code)
