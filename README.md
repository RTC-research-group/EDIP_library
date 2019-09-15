# EDIP_library
Event-driven IP library for event-based vision sensors processing and motor control

The following folders contain VHDL circuit description that can be synthesized and implemented on FPGA for event-based processing.

1. Background Activity Filter: It's aim is to remove those not correlated events (both in time and space) coming out from a DVS sensor. 

2. MaskFilter: It can be used for getting ride of a set of pixels from the visual field of a DVS sensor. It is configured through an observation period.

3. ObjectMotionDetection: This is the VHDL description of the cluster object tracker available in the software jAER. It also includes a module for velocity estimation and a block for pattern matching object detection. These tracker cells work in a cascade way.

4. Object Motion Detection: From the EU Visualise project, in collaboration with RTC-Lab form Univ. Sevilla (through an internship of Diederik P. Moeys in 2016), a VHDL that describes the behaviour of the Retinal Ganglion Cell that detects motion is available here.

5. Approaching Cell: From the same EU Visualise project collaboration, this second functionality was implemented by Hongjie Liu and RTC-Lab including an intership in 2017.

6. Exmaple Project Object Trackers and OMC: This folder contains all the source files needed to implement the system described in (IEEEACCESS: https://doi.org/10.1109/ACCESS.2019.2941282). This system has been tested in the AERtools platforms designed by RTC-Lab and manufactured by COBER S.L. (www.t-cober.es)

7. WordSerial-DAVIS to PAER-CAVIAR translator: These VHDL files contains the needed logic to translate the AER format used in the DAVIS to the AER format used in CAVIAR connectors, boards and chips, which is compatible with ROME 20-pin one. 

8. Spike-based PID motor controller: This folder contains a set of VHDL files that implements a PID controller for DC motors in the spike-domain, using as a principle the PFM (pulse frequency modulation) instead of the classic PWM (pulse width modulation) to power the motors. This approach avoid latencies in converting the control signal to PWM and save power.

Please, reference the work included in each README.md file of each folder, and conctact the authors for any question or collaboration.

