import serial
import datetime
import time
import os
import sys

#Control_port_number = int(sys.argv[1])
Control_port_number = int(15) #COM Port
#State = int(sys.argv[2])
State = int(1) # ON / OFF

#Carbon256=COM14
#Carbon512=COM11
#Carbon1TB=COM13

#Nano256=COM15
#Nano512=COM16
#Nano1TB=COM20
#Nano2TB=COM28

#HP256=COM17
#HP512=COM18

#HP(Gen3)AMD_256GB=COM26
#HP(Gen3)830G6_256GB=COM24
#HP(Gen3)830G6_512GB=COM25



###***### PROJECT ATHENA ###***###

#LenovoX1Carobon = COM21

Control_port = serial.Serial(	# connect to the INA3221 though a UART to I2C brige
    port=(''.join(['COM',str(Control_port_number)])),
    baudrate=9600,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1
)

if State == 1:
	serialcmd = '1'
	Control_port.write(serialcmd.encode())	       # Short 1-A
elif State == 0:
	serialcmd = 'Q'
	Control_port.write(serialcmd.encode())	       # Open 1-A
Control_port.close()          # close port
