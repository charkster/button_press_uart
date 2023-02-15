# button_press_uart
This FPGA design measures the "round trip" latency from when the FPGA sends a UART byte to the host and a host UART response is received by the FPGA. A button press starts the process and the host must be running the included Python script. Multiple button presses are allowed and then averaged to calculate an average latency.

If the USB UART interface is used to load/retrieve data processed by the FPGA, I was curious as to how quickly the FPGA could alert the host PC and then for the host to send a response to the FPGA. The FPGA has an internal counter (in 10us steps) which starts counting when one of the FPGA board buttons is pressed. The button press also immediately causes the FPGA to send a single byte to the host PC. The PC is running a Python script which receives the UART byte and immedately sends a response byte to the FPGA. Upon receiving the response byte the FPGA samples the internal counter and sends the count back to the host PC. The Python script reports the received counter value (after multiplying it by 10us). The Python script can be easily modified to allow for multiple button presses, for an average latency to be calcuated.

The FPGA's top-level can be modified for any FPGA board (I have tried Tang Nano 9k and CMOD-A7). Maximum UART baudrate for Tang Nano is 1Mbit/s, Tang Nano 9k is 3Mbit/s and CMOD-A7 is 12Mbit/s.


I have measured the latency on 2 of my PCs and my RPi4. Tang Nano 9k generally does not see a latency greater than 1/3 of a millisecond, and some latencies were as low as 180us. I measured the latency manually with a logic analyzer to ensure that the FPGA internal counter was providing accurate results. CMOD-A7 had much, much higher latency with the offical FTDI FT2232H IC (ironic that the software emulated version is higher performance). I see at least 2 milliseconds of latency, and most times I will reach the maximum 2.55ms count.

![picture](https://github.com/charkster/button_press_uart/blob/main/images/button_press_uart_latency_rpi4.png)


A practical application of this would be if the FPGA is connected to an I2S microphone and a VAD (Voice Activity Detection) algorithm is running on the FPGA. If no audio data is to be lost, how large of a buffer is needed to hold voice audio samples? If the mono microphone is saving 24bit (3 byte) samples at 16kHz, 3 bytes need to be saved every 62.5us. If the round trip latency is 330us, 6 samples (18 bytes) of memory would be needed. Most FPGA algorithms will just stream results to the host PC, but there are times when the round trip latency is needed for design decisions.
