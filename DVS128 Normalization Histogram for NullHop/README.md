DVS128 Normalization and histogram collection circuit for NullHop use

This zip file can be included as an IP in a Xilinx Vivado project. It includes the source files used for the paper:

https://arxiv.org/abs/1905.07419

Also submitted to ICONS21.
This circuit includes a background activity filter connected to a system described part in VHDL and part in HLS C++ that collects 2k events in histogram stored in a double buffer architecture. It also keeps normalising each collected histogram and transmit it in a stream way to the NullHop CNN accelerator. 

NullHop is described in this paper: https://ieeexplore.ieee.org/abstract/document/8421093

Background activity filter and other event-based DVS postprocessing algorithms are described in this paper: https://ieeexplore.ieee.org/abstract/document/8836544

The system has been developed for the DVS128 retina described in this paper: https://ieeexplore.ieee.org/abstract/document/4444573