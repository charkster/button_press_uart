# Run this before pressing button. Button press starts the FPGA internal counter and sends a 0x88 byte value to host.
# Host recieves the 0x88 byte and sends back an arbitrary byte value. Once the FPGA receives the byte value it samples the
#  internal counter and sends the value to the host. The counter value is in 10us steps (as a byte can have a value of 0 to 255).
# The "num_tries_orig" variable represents the number of button presses to include in the average result. It can be changed.
# The received counter value represents the round trip latency from when a FPGA event can be communicated to the host, a host response
#  is sent and that response is received by the FPGA. In most cases it is about 1/3 of a millisecond.

import serial


port = serial.Serial(port='/dev/ttyUSB1', baudrate=3000000, bytesize=8, parity='N', stopbits=1, timeout=0.01)


num_tries_orig = 5              # adjust this number for more samples in average
num_tries      = num_tries_orig # this will decrement
sum_microsec   = 0
while (num_tries > 0):
	port.reset_input_buffer()
	num_rx_bytes_read = 2 # this needs to remain fixed at 2
	while (num_rx_bytes_read > 0):
		bytesToRead = port.in_waiting
		if (bytesToRead != 0):
			port.write(b'\x0c') # arbitrary value, when FPGA recieves this value counter is sampled and sent back to host 
			num_rx_bytes_read = num_rx_bytes_read - 1
	rx_bytes = port.read(2) # first byte is the 0x88 that the FPGA sends when button is pressed, second is timer value
	num_microsec = int(rx_bytes[1]) * 10 # FPGA counter steps size is 10us (a count of 1 is 10us, a count of 20 is 200us)
	sum_microsec += num_microsec
	print("{:d}us".format(num_microsec))
	num_tries = num_tries - 1

print("Average latency is {:d} microseconds".format(int(sum_microsec/num_tries_orig)))
