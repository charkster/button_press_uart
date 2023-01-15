# button_press_uart
This FPGA design measures the "round trip" latency from when the FPGA sends a UART byte to the host and a host UART response is received by the FPGA. A button press starts the process and the host must be running the included Python script. Multiple button presses are allowed and then averaged to calculate an average latency.

If the USB UART interface is used to load/retreive data processed by the FPGA, I was curious as to how quickly the FPGA could alert the host PC and then for the host to send a response to the FPGA. The FPGA has an internal counter (in 10us steps) which starts counting when one of the FPGA board buttons is pressed. The button press also immediately causes the FPGA to send a single byte to the host PC. The PC is running a Python script which receives the UART byte and immedately sends a response byte to the FPGA. Upon receiving the response byte the FPGA samples the internal counter and sends the count back to the host PC. The Python script reports the received counter value (after multiplying it by 10us). The Python script can be easily modified to allow for multiple button presses to be used to allow for an average latency to be calcuated.

The FPGA's top-level can be modified for any FPGA board (I have tried Tang Nano, Tang Nano 9k and CMOD-A7). Maximum UART baudrate for Tang Nano is 1Mbit/s, Tang Nano 9k is 3Mbit/s and CMOD-A7 is 12Mbit/s.


I have measured the latency on 2 of my PCs and my RPi4. I have not seen a latency greater than 1/3 of a millisecond, and some latencies were as low as 180us.
