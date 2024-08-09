# dsss_802.11_b_1Mbps
This is a verilog implementation of the 1 Mbps receiver for 802.11b wifi 
The simulation was written in Octave but should work with the matlab with slight changes. Verilog simulation was checked using modelsim.
One of the assumptions was that the sample rate of the input signal is 20 Msps. The Barker code sequence is resampled to the 20MHz from 22 MHz. 
The future plan was, maybe, to interface this code to the openwifi project
