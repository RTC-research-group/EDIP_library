package es.us.atc.jaer.chips.FpgaConfig;

import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.Iterator;

import net.sf.jaer.chip.AEChip;
import net.sf.jaer.event.EventPacket;
import net.sf.jaer.eventprocessing.EventFilter2D;

import org.usb4java.BufferUtils;
import org.usb4java.Device;
import org.usb4java.DeviceDescriptor;
import org.usb4java.DeviceHandle;
import org.usb4java.DeviceList;
import org.usb4java.LibUsb;

import es.us.atc.jaer.hardwareinterface.OpalKellyFX2Monitor;
import es.us.atc.jaer.hardwareinterface.OpalKellyFX2MonitorFactory;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
import static net.sf.jaer.eventprocessing.EventFilter.log;
import net.sf.jaer.hardwareinterface.HardwareInterfaceException;

public class ATCBioRobAERrobotConfig extends EventFilter2D {

    private int HWInterfaceID = getInt("hwinterfaceId",1);
    
    private int J1_sensor_value = getInt("J1_sensor_value", 0);
    private int J2_sensor_value = getInt("J2_sensor_value", 0);
    private int J3_sensor_value = getInt("J3_sensor_value", 0);
    private int J4_sensor_value = getInt("J4_sensor_value", 0);
    
    private int leds_M1 = getInt("leds_M1", 2); //from 0 to 15
    private int leds_M2 = getInt("leds_M2", 2);
    private int leds_M3 = getInt("leds_M3", 2);
    private int leds_M4 = getInt("leds_M4", 2); 
    private int Ref_M1  = getInt("Ref_M1", 0); //from 0 to 65535
    private int Ref_M2  = getInt("Ref_M2", 0); 
    private int Ref_M3  = getInt("Ref_M3", 0); 
    private int Ref_M4  = getInt("Ref_M4", 0);
    
    private int PI_bank_select_M1 = 3;//getInt("PI_bank_select_M1", 3); //0 to 7, 2 & 3 valid
    private int PI_bank_select_M2 = 3;//getInt("PI_bank_select_M2", 3); //0 to 7, 2 & 3 valid
    private int PI_bank_select_M3 = 3;//getInt("PI_bank_select_M3", 3); //0 to 7, 2 & 3 valid
    private int PI_bank_select_M4 = 3;//getInt("PI_bank_select_M4", 3); //0 to 7, 2 & 3 valid

    private int PI_FD_bank0_12bits_M1 = 512;//getInt("PI_FD_bank0_12bits_M1", 512);
    private int PI_FD_bank0_12bits_M2 = 512;//getInt("PI_FD_bank0_12bits_M2", 512);
    private int PI_FD_bank0_12bits_M3 = 512;//getInt("PI_FD_bank0_12bits_M3", 512);
    private int PI_FD_bank0_12bits_M4 = 512;//getInt("PI_FD_bank0_12bits_M4", 512);
    private int PI_FD_bank1_14bits_M1 = 512;//getInt("PI_FD_bank1_14bits_M1", 512);
    private int PI_FD_bank1_14bits_M2 = 512;//getInt("PI_FD_bank1_14bits_M2", 512);
    private int PI_FD_bank1_14bits_M3 = 512;//getInt("PI_FD_bank1_14bits_M3", 512);
    private int PI_FD_bank1_14bits_M4 = 512;//getInt("PI_FD_bank1_14bits_M4", 512);
    private int PI_FD_bank2_16bits_M1 = 512;//getInt("PI_FD_bank2_16bits_M1", 512);
    private int PI_FD_bank2_16bits_M2 = 512;//getInt("PI_FD_bank2_16bits_M2", 512);
    private int PI_FD_bank2_16bits_M3 = 512;//getInt("PI_FD_bank2_16bits_M3", 512);
    private int PI_FD_bank2_16bits_M4 = 512;//getInt("PI_FD_bank2_16bits_M4", 512);
    private int PI_FD_bank3_18bits_M1 = getInt("PI_FD_bank3_18bits_M1", 4096);
    private int PI_FD_bank3_18bits_M2 = getInt("PI_FD_bank3_18bits_M2", 4096);
    private int PI_FD_bank3_18bits_M3 = getInt("PI_FD_bank3_18bits_M3", 4096);
    private int PI_FD_bank3_18bits_M4 = getInt("PI_FD_bank3_18bits_M4", 4096);

    private int PD_bank_select_M1 = 3;//getInt("PD_bank_select_M1", 3); //0 to 7, 2 & 3 valid
    private int PD_bank_select_M2 = 3;//getInt("PD_bank_select_M2", 3); //0 to 7, 2 & 3 valid
    private int PD_bank_select_M3 = 3;//getInt("PD_bank_select_M3", 3); //0 to 7, 2 & 3 valid
    private int PD_bank_select_M4 = 3;//getInt("PD_bank_select_M4", 3); //0 to 7, 2 & 3 valid

    private int PD_FD_bank0_16bits_M1 = 512;//getInt("PD_FD_bank0_16bits_M1", 512);
    private int PD_FD_bank0_16bits_M2 = 512;//getInt("PD_FD_bank0_16bits_M2", 512);
    private int PD_FD_bank0_16bits_M3 = 512;//getInt("PD_FD_bank0_16bits_M3", 512);
    private int PD_FD_bank0_16bits_M4 = 512;//getInt("PD_FD_bank0_16bits_M4", 512);
    private int PD_FD_bank1_18bits_M1 = 512;//getInt("PD_FD_bank1_18bits_M1", 512);
    private int PD_FD_bank1_18bits_M2 = 512;//getInt("PD_FD_bank1_18bits_M2", 512);
    private int PD_FD_bank1_18bits_M3 = 512;//getInt("PD_FD_bank1_18bits_M3", 512);
    private int PD_FD_bank1_18bits_M4 = 512;//getInt("PD_FD_bank1_18bits_M4", 512);
    private int PD_FD_bank2_20bits_M1 = 512;//getInt("PD_FD_bank2_20bits_M1", 512);
    private int PD_FD_bank2_20bits_M2 = 512;//getInt("PD_FD_bank2_20bits_M2", 512);
    private int PD_FD_bank2_20bits_M3 = 512;//getInt("PD_FD_bank2_20bits_M3", 512);
    private int PD_FD_bank2_20bits_M4 = 512;//getInt("PD_FD_bank2_20bits_M4", 512);
    private int PD_FD_bank3_22bits_M1 = 512;//getInt("PD_FD_bank3_22bits_M1", 4096);
    private int PD_FD_bank3_22bits_M2 = 512;//getInt("PD_FD_bank3_22bits_M2", 4096);
    private int PD_FD_bank3_22bits_M3 = 512;//getInt("PD_FD_bank3_22bits_M3", 4096);
    private int PD_FD_bank3_22bits_M4 = 512;//getInt("PD_FD_bank3_22bits_M4", 4096);

    private int EI_bank_select_M1 = 3;//getInt("EI_bank_select_M1", 3); //0 to 7, 2 & 3 valid
    private int EI_FD_bank0_12bits_M1 = 512;//getInt("EI_FD_bank0_12bits_M1", 512);
    private int EI_FD_bank1_14bits_M1 = 512;//getInt("EI_FD_bank1_14bits_M1", 512);
    private int EI_FD_bank2_16bits_M1 = 512;//getInt("EI_FD_bank2_16bits_M1", 512);
    private int EI_FD_bank3_18bits_M1 = getInt("EI_FD_bank3_18bits_M1", 16);
    private int EI_bank_select_M2 = 3;//getInt("EI_bank_select_M2", 3); //0 to 7, 2 & 3 valid
    private int EI_FD_bank0_12bits_M2 = 512;//getInt("EI_FD_bank0_12bits_M2", 512);
    private int EI_FD_bank1_14bits_M2 = 512;//getInt("EI_FD_bank1_14bits_M2", 512);
    private int EI_FD_bank2_16bits_M2 = 512;//getInt("EI_FD_bank2_16bits_M2", 512);
    private int EI_FD_bank3_18bits_M2 = getInt("EI_FD_bank3_18bits_M2", 16);
    private int EI_bank_select_M3 = 3;//getInt("EI_bank_select_M3", 3); //0 to 7, 2 & 3 valid
    private int EI_FD_bank0_12bits_M3 = 512;//getInt("EI_FD_bank0_12bits_M3", 512);
    private int EI_FD_bank1_14bits_M3 = 512;//getInt("EI_FD_bank1_14bits_M3", 512);
    private int EI_FD_bank2_16bits_M3 = 512;//getInt("EI_FD_bank2_16bits_M3", 512);
    private int EI_FD_bank3_18bits_M3 = getInt("EI_FD_bank3_18bits_M3", 16);
    private int EI_bank_select_M4 = 3;//getInt("EI_bank_select_M4", 3); //0 to 7, 2 & 3 valid
    private int EI_FD_bank0_12bits_M4 = 512;//getInt("EI_FD_bank0_12bits_M4", 512);
    private int EI_FD_bank1_14bits_M4 = 512;//getInt("EI_FD_bank1_14bits_M4", 512);
    private int EI_FD_bank2_16bits_M4 = 512;//getInt("EI_FD_bank2_16bits_M4", 512);
    private int EI_FD_bank3_18bits_M4 = getInt("EI_FD_bank3_18bits_M4", 16);

    private int SpikeExpansor_M1 = getInt("SpikeExpansor_M1", 0x0400); // from 0 to 0xffff
    private int SpikeExpansor_M2 = getInt("SpikeExpansor_M2", 0x0400); // from 0 to 0xffff
    private int SpikeExpansor_M3 = getInt("SpikeExpansor_M3", 0x0400); // from 0 to 0xffff
    private int SpikeExpansor_M4 = getInt("SpikeExpansor_M4", 0x0400); // from 0 to 0xffff

    private int Scan_Init_Value  = getInt("Scan_Init_Value", -500);
    private int Scan_Final_Value = getInt("Scan_Final_Value", 500);
    private int Scan_Step_Value  = getInt("Scan_Step_Value", 10);
    private int Scan_Wait_Time   = getInt("Scan_Wait_Time", 100);

    private boolean AERRobot_USBEnable = getBoolean("AERRobot_USBEnable", false);
    private boolean AERNodeOKAERtoolEnable = getBoolean("AERNodeOKAERtoolEnable", false);
    
    private boolean Reset = getBoolean("Reset", false);
    private boolean Reset_once = false;
    
    

    // FPGA clock speed in MegaHertz (MHz) for time conversion.
    private final int CLOCK_SPEED = 50;
    private OpalKellyFX2Monitor OKHardwareInterface;
//    check
    Logger logger = Logger.getLogger("BioRobLog");  
    FileHandler flog; 
    /**
     *
     * @param chip
     */
    public ATCBioRobAERrobotConfig(final AEChip chip) {
        super(chip);
        try
        {
            OKHardwareInterface = (OpalKellyFX2Monitor)OpalKellyFX2MonitorFactory.instance().getFirstAvailableInterface();
        }
        catch (HardwareInterfaceException ex) 
        {
            log.warning(ex.toString());
        }
        
        initFilter();
        final String sc="Scan parameters", m1 = "1) Motor 1", m2 = "2) Motor 2", m3 = "3) Motor 3", m4 = "4) Motor 4", hw="5) HW Interface", j1="Joint sensors";
        
        setPropertyTooltip(j1, "J1_sensor_value", "16 bits read from the SPI slave postion sensor of the J1");
        setPropertyTooltip(j1, "J2_sensor_value", "16 bits read from the SPI slave postion sensor of the J2");
        setPropertyTooltip(j1, "J3_sensor_value", "16 bits read from the SPI slave angle postion sensor of the J3");
        setPropertyTooltip(j1, "J4_sensor_value", "16 bits read from the SPI slave angle postion sensor of the J4");
        
        setPropertyTooltip(m1, "leds_M1", "0 to 15 for turning on/off leds of Motor 1");
//        setPropertyTooltip(m1, "PI_bank_select_M1", "Enable for I parts on PID M1 (0-3), 12, 14, 16 & 16-bits lenghts");
//        setPropertyTooltip(m1, "PI_FD_bank0_12bits_M1", "Frequency divider for I part bank 0 12-bits of PID M1");
//        setPropertyTooltip(m1, "PI_FD_bank1_14bits_M1", "Frequency divider for I part bank 1 14-bits of PID M1");
//        setPropertyTooltip(m1, "PI_FD_bank2_16bits_M1", "Frequency divider for I part bank 2 16-bits of PID M1");
        setPropertyTooltip(m1, "PI_FD_bank3_18bits_M1", "Frequency divider for I part bank 3 18-bits of PID M1");
//        setPropertyTooltip(m1, "PD_bank_select_M1", "Enable for D parts on PID M1 (0-3), 16, 18, 20, 22-bits lengths");
//        setPropertyTooltip(m1, "PD_FD_bank0_16bits_M1", "Frequency divider for D part bank 0 16-bits of PID M1");
//        setPropertyTooltip(m1, "PD_FD_bank1_18bits_M1", "Frequency divider for D part bank 1 18-bits of PID M1");
//        setPropertyTooltip(m1, "PD_FD_bank2_20bits_M1", "Frequency divider for D part bank 2 20-bits of PID M1");
        setPropertyTooltip(m1, "PD_FD_bank3_22bits_M1", "Frequency divider for D part bank 3 22-bits of PID M1");
//        setPropertyTooltip(m1, "EI_bank_select_M1", "Enable for ENC INT parts on PID M1 (0-3), 12, 14, 16, 18-bits lengths");
//        setPropertyTooltip(m1, "EI_FD_bank0_12bits_M1", "Frequency divider for ENC INT part bank 0 12-bits of M1");
//        setPropertyTooltip(m1, "EI_FD_bank1_14bits_M1", "Frequency divider for ENC INT part bank 1 14-bits of M1");
//        setPropertyTooltip(m1, "EI_FD_bank2_16bits_M1", "Frequency divider for ENC INT part bank 2 16-bits of M1");
        setPropertyTooltip(m1, "EI_FD_bank3_18bits_M1", "Frequency divider for ENC INT part bank 3 18-bits of M1");
        setPropertyTooltip(m1, "SpikeExpansor_M1", "Spike Expansor for PID output of M1 (0 to 0xffff)");
        setPropertyTooltip(m1, "Ref_M1", "Reference value for M1 PID 0 to 0xffff");
        setPropertyTooltip(sc, "Scan_Init_Value", "Insert a value from 65535 (-1) to 32768 (-32767)");
        setPropertyTooltip(sc, "Scan_Final_Value", "Insert a value from 1 to 32767");
        setPropertyTooltip(sc, "Scan_Step_Value", "Insert a step value from 10 to 100");
        setPropertyTooltip(sc, "Scan_Wait_Time", "Inser a waiting time between steps in milliseconds"); 

        setPropertyTooltip(m2, "leds_M2", "0 to 15 for turning on/off leds of Motor 2");
//        setPropertyTooltip(m2, "PI_bank_select_M2", "Enable for I parts on PID M2 (0-3), 12, 14, 16 & 16-bits lenghts");
//        setPropertyTooltip(m2, "PI_FD_bank0_12bits_M2", "Frequency divider for I part bank 0 12-bits of PID M2");
//        setPropertyTooltip(m2, "PI_FD_bank1_14bits_M2", "Frequency divider for I part bank 1 14-bits of PID M2");
//        setPropertyTooltip(m2, "PI_FD_bank2_16bits_M2", "Frequency divider for I part bank 2 16-bits of PID M2");
        setPropertyTooltip(m2, "PI_FD_bank3_18bits_M2", "Frequency divider for I part bank 3 18-bits of PID M2");
//        setPropertyTooltip(m2, "PD_bank_select_M2", "Enable for D parts on PID M1 (0-3), 16, 18, 20, 22-bits lengths");
//        setPropertyTooltip(m2, "PD_FD_bank0_16bits_M2", "Frequency divider for D part bank 0 16-bits of PID M2");
//        setPropertyTooltip(m2, "PD_FD_bank1_18bits_M2", "Frequency divider for D part bank 1 18-bits of PID M2");
//        setPropertyTooltip(m2, "PD_FD_bank2_20bits_M2", "Frequency divider for D part bank 2 20-bits of PID M2");
        setPropertyTooltip(m2, "PD_FD_bank3_22bits_M2", "Frequency divider for D part bank 3 22-bits of PID M2");
//        setPropertyTooltip(m2, "EI_bank_select_M2", "Enable for ENC INT parts on PID M2 (0-3), 12, 14, 16, 18-bits lengths");
//        setPropertyTooltip(m2, "EI_FD_bank0_12bits_M2", "Frequency divider for ENC INT part bank 0 12-bits of M2");
//        setPropertyTooltip(m2, "EI_FD_bank1_14bits_M2", "Frequency divider for ENC INT part bank 1 14-bits of M2");
//        setPropertyTooltip(m2, "EI_FD_bank2_16bits_M2", "Frequency divider for ENC INT part bank 2 16-bits of M2");
        setPropertyTooltip(m2, "EI_FD_bank3_18bits_M2", "Frequency divider for ENC INT part bank 3 18-bits of M2");
        setPropertyTooltip(m2, "SpikeExpansor_M2", "Spike Expansor for PID output of M2 (0 to 0xffff)");
        setPropertyTooltip(m2, "Ref_M2", "Reference value for M2 PID 0 to 0xffff");

        setPropertyTooltip(m3, "leds_M3", "0 to 15 for turning on/off leds of Motor 3");
//        setPropertyTooltip(m3, "PI_bank_select_M3", "Enable for I parts on PID M3 (0-3), 12, 14, 16 & 16-bits lenghts");
//        setPropertyTooltip(m3, "PI_FD_bank0_12bits_M3", "Frequency divider for I part bank 0 12-bits of PID M3");
//        setPropertyTooltip(m3, "PI_FD_bank1_14bits_M3", "Frequency divider for I part bank 1 14-bits of PID M3");
//        setPropertyTooltip(m3, "PI_FD_bank2_16bits_M3", "Frequency divider for I part bank 2 16-bits of PID M3");
        setPropertyTooltip(m3, "PI_FD_bank3_18bits_M3", "Frequency divider for I part bank 3 18-bits of PID M3");
//        setPropertyTooltip(m3, "PD_bank_select_M3", "Enable for D parts on PID M1 (0-3), 16, 18, 20, 22-bits lengths");
//        setPropertyTooltip(m3, "PD_FD_bank0_16bits_M3", "Frequency divider for D part bank 0 16-bits of PID M3");
//        setPropertyTooltip(m3, "PD_FD_bank1_18bits_M3", "Frequency divider for D part bank 1 18-bits of PID M3");
//        setPropertyTooltip(m3, "PD_FD_bank2_20bits_M3", "Frequency divider for D part bank 2 20-bits of PID M3");
        setPropertyTooltip(m3, "PD_FD_bank3_22bits_M3", "Frequency divider for D part bank 3 22-bits of PID M3");
//        setPropertyTooltip(m3, "EI_bank_select_M3", "Enable for ENC INT parts on PID M2 (0-3), 12, 14, 16, 18-bits lengths");
//        setPropertyTooltip(m3, "EI_FD_bank0_12bits_M3", "Frequency divider for ENC INT part bank 0 12-bits of M3");
//        setPropertyTooltip(m3, "EI_FD_bank1_14bits_M3", "Frequency divider for ENC INT part bank 1 14-bits of M3");
//        setPropertyTooltip(m3, "EI_FD_bank2_16bits_M3", "Frequency divider for ENC INT part bank 2 16-bits of M3");
        setPropertyTooltip(m3, "EI_FD_bank3_18bits_M3", "Frequency divider for ENC INT part bank 3 18-bits of M3");
        setPropertyTooltip(m3, "SpikeExpansor_M3", "Spike Expansor for PID output of M3 (0 to 0xffff)");
        setPropertyTooltip(m3, "Ref_M3", "Reference value for M3 PID 0 to 0xffff");

        setPropertyTooltip(m4, "leds_M4", "0 to 15 for turning on/off leds of Motor 4");
//        setPropertyTooltip(m4, "PI_bank_select_M4", "Enable for I parts on PID M4 (0-3), 12, 14, 16 & 16-bits lenghts");
//        setPropertyTooltip(m4, "PI_FD_bank0_12bits_M4", "Frequency divider for I part bank 0 12-bits of PID M4");
//        setPropertyTooltip(m4, "PI_FD_bank1_14bits_M4", "Frequency divider for I part bank 1 14-bits of PID M4");
//        setPropertyTooltip(m4, "PI_FD_bank2_16bits_M4", "Frequency divider for I part bank 2 16-bits of PID M4");
        setPropertyTooltip(m4, "PI_FD_bank3_18bits_M4", "Frequency divider for I part bank 3 18-bits of PID M4");
//        setPropertyTooltip(m4, "PD_bank_select_M4", "Enable for D parts on PID M4 (0-3), 16, 18, 20, 22-bits lengths");
//        setPropertyTooltip(m4, "PD_FD_bank0_16bits_M4", "Frequency divider for D part bank 0 16-bits of PID M4");
//        setPropertyTooltip(m4, "PD_FD_bank1_18bits_M4", "Frequency divider for D part bank 1 18-bits of PID M4");
//        setPropertyTooltip(m4, "PD_FD_bank2_20bits_M4", "Frequency divider for D part bank 2 20-bits of PID M4");
        setPropertyTooltip(m4, "PD_FD_bank3_22bits_M4", "Frequency divider for D part bank 3 22-bits of PID M4");
//        setPropertyTooltip(m4, "EI_bank_select_M4", "Enable for ENC INT parts on PID M4 (0-3), 12, 14, 16, 18-bits lengths");
//        setPropertyTooltip(m4, "EI_FD_bank0_12bits_M4", "Frequency divider for ENC INT part bank 0 12-bits of M4");
//        setPropertyTooltip(m4, "EI_FD_bank1_14bits_M4", "Frequency divider for ENC INT part bank 1 14-bits of M4");
//        setPropertyTooltip(m4, "EI_FD_bank2_16bits_M4", "Frequency divider for ENC INT part bank 2 16-bits of M4");
        setPropertyTooltip(m4, "EI_FD_bank3_18bits_M4", "Frequency divider for ENC INT part bank 3 18-bits of M4");
        setPropertyTooltip(m4, "SpikeExpansor_M4", "Spike Expansor for PID output of M4 (0 to 0xffff)");
        setPropertyTooltip(m4, "Ref_M4", "Reference value for M4 PID 0 to 0xffff");

        // HW Interface selected
        setPropertyTooltip(hw, "AERRobot_USBEnable", "AERRobot (sensors + spike expansors) USB interface + SPI to AER-Node (sPID controllers)");
        
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                flog = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/BioRob_log_" + timeStamp + ".log");  
                logger.addHandler(flog);
                SimpleFormatter formatter = new SimpleFormatter();  
                flog.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  

    }

    // J1 sensor
    public void setJ1_sensor_value(final int sensor_J1) {
        this.J1_sensor_value = sensor_J1;
        putInt("J1_sensor_value", sensor_J1);
    }
    
    public int getJ1_sensor_value(){
        return J1_sensor_value;
    }
    // J2 sensor
    public void setJ2_sensor_value(final int sensor_J2) {
        this.J2_sensor_value = sensor_J2;
        putInt("J2_sensor_value", sensor_J2);
    }
    
    public int getJ2_sensor_value(){
        return J2_sensor_value;
    }
    // J3 sensor
    public void setJ3_sensor_value(final int sensor_J3) {
        this.J3_sensor_value = sensor_J3;
        putInt("J3_sensor_value", sensor_J3);
    }
    
    public int getJ3_sensor_value(){
        return J3_sensor_value;
    }
    // J4 sensor
    public void setJ4_sensor_value(final int sensor_J4) {
        this.J4_sensor_value = sensor_J4;
        putInt("J4_sensor_value", sensor_J4);
    }
    
    public int getJ4_sensor_value(){
        return J4_sensor_value;
    }
    // M1 parameters
    public void setleds_M1(final int leds_M1) {
        this.leds_M1 = leds_M1;
        putInt("leds_M1", leds_M1);
    }

    public int getleds_M1() {
        return leds_M1;
    }
    
    public static int getMinleds_M1() {
        return 0;
    }

    public static int getMaxleds_M1() {
        return 15;
    }

    public void setScan_Init_Value(final int Scan_Init_Value) {
        this.Scan_Init_Value = Scan_Init_Value;
        putInt("Scan_Init_Value", Scan_Init_Value);
    }

    public int getScan_Init_Value() {
        return Scan_Init_Value;
    }

    public static int getMinScan_Init_Value() {
        return -32767;
    }

    public static int getMaxScan_Init_Value() {
        return 32767;
    }
    
    public void setScan_Final_Value(final int Scan_Final_Value) {
        this.Scan_Final_Value = Scan_Final_Value;
        putInt("Scan_Final_Value", Scan_Final_Value);
    }

    public int getScan_Final_Value() {
        return Scan_Final_Value;
    }

    public static int getMinScan_Final_Value() {
        return -32767;
    }

    public static int getMaxScan_Final_Value() {
        return 32767;
    }
    
    public void setScan_Step_Value(final int Scan_Step_Value) {
        this.Scan_Step_Value = Scan_Step_Value;
        putInt("Scan_Step_Value", Scan_Step_Value);
    }

    public int getScan_Step_Value() {
        return Scan_Step_Value;
    }

    public static int getMinScan_Step_Value() {
        return 10;
    }

    public static int getMaxScan_Step_Value() {
        return 100;
    }
    
    public void setScan_Wait_Time(final int Scan_Wait_Time) {
        this.Scan_Wait_Time = Scan_Wait_Time;
        putInt("Scan_Wait_Time", Scan_Wait_Time);
    }

    public int getScan_Wait_Time() {
        return Scan_Wait_Time;
    }

    public static int getMinScan_Wait_Time() {
        return 10;
    }

    public static int getMaxScan_Wait_Time() {
        return 1000;
    }
    
/*    public void setPI_bank_select_M1(final int PI_bank_select_M1) {
        this.PI_bank_select_M1 = PI_bank_select_M1;
        putInt("PI_bank_select_M1", PI_bank_select_M1);
    }

    public int getPI_bank_select_M1() {
        return PI_bank_select_M1;
    }

    public static int getMinPI_bank_select_M1() {
        return 0;
    }

    public static int getMaxPI_bank_select_M1() {
        return 4;
    }*/
    
    /*public void setPD_bank_select_M1(final int PD_bank_select_M1) {
        this.PD_bank_select_M1 = PD_bank_select_M1;
        putInt("PD_bank_select_M1", PD_bank_select_M1);
    }

    public int getPD_bank_select_M1() {
        return PD_bank_select_M1;
    }

    public static int getMinPD_bank_select_M1() {
        return 0;
    }

    public static int getMaxPD_bank_select_M1() {
        return 3;
    }*/
    
    /*public void setEI_bank_select_M1(final int EI_bank_select_M1) {
        this.EI_bank_select_M1 = EI_bank_select_M1;
        putInt("EI_bank_select_M1", EI_bank_select_M1);
    }

    public int getEI_bank_select_M1() {
        return EI_bank_select_M1;
    }

    public static int getMinEI_bank_select_M1() {
        return 0;
    }

    public static int getMaxEI_bank_select_M1() {
        return 3;
    }*/

    /*public void setPI_FD_bank0_12bits_M1(final int PI_FD_bank0_12bits_M1) {
        this.PI_FD_bank0_12bits_M1 = PI_FD_bank0_12bits_M1;
        putInt("PI_FD_bank0_12bits_M1", PI_FD_bank0_12bits_M1);
    }

    public int getPI_FD_bank0_12bits_M1() {
        return PI_FD_bank0_12bits_M1;
    }

    public static int getMinPI_FD_bank0_12bits_M1() {
        return 0;
    }

    public static int getMaxPI_FD_bank0_12bits_M1() {
        return (65535);
    }*/

    /*public void setPI_FD_bank1_14bits_M1(final int PI_FD_bank1_14bits_M1) {
        this.PI_FD_bank1_14bits_M1 = PI_FD_bank1_14bits_M1;
        putInt("PI_FD_bank1_14bits_M1", PI_FD_bank1_14bits_M1);
    }

    public int getPI_FD_bank1_14bits_M1() {
        return PI_FD_bank1_14bits_M1;
    }

    public static int getMinPI_FD_bank1_14bits_M1() {
        return 0;
    }

    public static int getMaxPI_FD_bank1_14bits_M1() {
        return (65535);
    }*/

    /*public void setPI_FD_bank2_16bits_M1(final int PI_FD_bank2_16bits_M1) {
        this.PI_FD_bank2_16bits_M1 = PI_FD_bank2_16bits_M1;
        putInt("PI_FD_bank2_16bits_M1", PI_FD_bank2_16bits_M1);
    }

    public int getPI_FD_bank2_16bits_M1() {
        return PI_FD_bank2_16bits_M1;
    }

    public static int getMinPI_FD_bank2_16bits_M1() {
        return 0;
    }

    public static int getMaxPI_FD_bank2_16bits_M1() {
        return (65535);
    }*/

    public void setPI_FD_bank3_18bits_M1(final int PI_FD_bank3_18bits_M1) {
        this.PI_FD_bank3_18bits_M1 = PI_FD_bank3_18bits_M1;
        putInt("PI_FD_bank3_18bits_M1", PI_FD_bank3_18bits_M1);
    }

    public int getPI_FD_bank3_18bits_M1() {
        return PI_FD_bank3_18bits_M1;
    }

    public static int getMinPI_FD_bank3_18bits_M1() {
        return 0;
    }

    public static int getMaxPI_FD_bank3_18bits_M1() {
        return (65535);
    }

    /*public void setEI_FD_bank0_12bits_M1(final int EI_FD_bank0_12bits_M1) {
        this.EI_FD_bank0_12bits_M1 = EI_FD_bank0_12bits_M1;
        putInt("EI_FD_bank0_12bits_M1", EI_FD_bank0_12bits_M1);
    }

    public int getEI_FD_bank0_12bits_M1() {
        return EI_FD_bank0_12bits_M1;
    }

    public static int getMinEI_FD_bank0_12bits_M1() {
        return 0;
    }

    public static int getMaxEI_FD_bank0_12bits_M1() {
        return (65535);
    }*/

    /*public void setEI_FD_bank1_14bits_M1(final int EI_FD_bank1_14bits_M1) {
        this.EI_FD_bank1_14bits_M1 = EI_FD_bank1_14bits_M1;
        putInt("EI_FD_bank1_14bits_M1", EI_FD_bank1_14bits_M1);
    }

    public int getEI_FD_bank1_14bits_M1() {
        return EI_FD_bank1_14bits_M1;
    }

    public static int getMinEI_FD_bank1_14bits_M1() {
        return 0;
    }

    public static int getMaxEI_FD_bank1_14bits_M1() {
        return (65535);
    }*/

    /*public void setEI_FD_bank2_16bits_M1(final int EI_FD_bank2_16bits_M1) {
        this.EI_FD_bank2_16bits_M1 = EI_FD_bank2_16bits_M1;
        putInt("EI_FD_bank2_16bits_M1", EI_FD_bank2_16bits_M1);
    }

    public int getEI_FD_bank2_16bits_M1() {
        return EI_FD_bank2_16bits_M1;
    }

    public static int getMinEI_FD_bank2_16bits_M1() {
        return 0;
    }

    public static int getMaxEI_FD_bank2_16bits_M1() {
        return (65535);
    }*/

    public void setEI_FD_bank3_18bits_M1(final int EI_FD_bank3_18bits_M1) {
        this.EI_FD_bank3_18bits_M1 = EI_FD_bank3_18bits_M1;
        putInt("EI_FD_bank3_18bits_M1", EI_FD_bank3_18bits_M1);
    }

    public int getEI_FD_bank3_18bits_M1() {
        return EI_FD_bank3_18bits_M1;
    }

    public static int getMinEI_FD_bank3_18bits_M1() {
        return 0;
    }

    public static int getMaxEI_FD_bank3_18bits_M1() {
        return (65535);
    }

    /*public void setPD_FD_bank0_16bits_M1(final int PD_FD_bank0_16bits_M1) {
        this.PD_FD_bank0_16bits_M1 = PD_FD_bank0_16bits_M1;
        putInt("PD_FD_bank0_16bits_M1", PD_FD_bank0_16bits_M1);
    }

    public int getPD_FD_bank0_16bits_M1() {
        return PD_FD_bank0_16bits_M1;
    }

    public static int getMinPD_FD_bank0_16bits_M1() {
        return 0;
    }

    public static int getMaxPD_FD_bank0_16bits_M1() {
        return (65535);
    }*/

    /*public void setPD_FD_bank1_18bits_M1(final int PD_FD_bank1_18bits_M1) {
        this.PD_FD_bank1_18bits_M1 = PD_FD_bank1_18bits_M1;
        putInt("PD_FD_bank1_18bits_M1", PD_FD_bank1_18bits_M1);
    }

    public int getPD_FD_bank1_18bits_M1() {
        return PD_FD_bank1_18bits_M1;
    }

    public static int getMinPD_FD_bank1_18bits_M1() {
        return 0;
    }

    public static int getMaxPD_FD_bank1_18bits_M1() {
        return (65535);
    }*/

    /*public void setPD_FD_bank2_20bits_M1(final int PD_FD_bank2_20bits_M1) {
        this.PD_FD_bank2_20bits_M1 = PD_FD_bank2_20bits_M1;
        putInt("PD_FD_bank2_20bits_M1", PD_FD_bank2_20bits_M1);
    }

    public int getPD_FD_bank2_20bits_M1() {
        return PD_FD_bank2_20bits_M1;
    }

    public static int getMinPD_FD_bank2_20bits_M1() {
        return 0;
    }

    public static int getMaxPD_FD_bank2_20bits_M1() {
        return (65535);
    }*/

    public void setPD_FD_bank3_22bits_M1(final int PD_FD_bank3_22bits_M1) {
        this.PD_FD_bank3_22bits_M1 = PD_FD_bank3_22bits_M1;
        putInt("PD_FD_bank3_22bits_M1", PD_FD_bank3_22bits_M1);
    }

    public int getPD_FD_bank3_22bits_M1() {
        return PD_FD_bank3_22bits_M1;
    }

    public static int getMinPD_FD_bank3_22bits_M1() {
        return 0;
    }

    public static int getMaxPD_FD_bank3_22bits_M1() {
        return (65535);
    }

    public void setSpikeExpansor_M1(final int SpikeExpansor_M1) {
        this.SpikeExpansor_M1 = SpikeExpansor_M1;
        putInt("SpikeExpansor_M1", SpikeExpansor_M1);
    }

    public int getSpikeExpansor_M1() {
        return SpikeExpansor_M1;
    }

    public static int getMinSpikeExpansor_M1() {
        return 0;
    }

    public static int getMaxSpikeExpansor_M1() {
        return (65535);
    }

    public void setRef_M1(final int Ref_M1) {
        this.Ref_M1 = Ref_M1;
        putInt("Ref_M1", Ref_M1);
    }

    public int getRef_M1() {
        return Ref_M1;
    }

    public static int getMinRef_M1() {
        return 0;
    }

    public static int getMaxRef_M1() {
        return (65535);
    }

    
    // M2 parameters
    public void setleds_M2(final int leds_M2) {
        this.leds_M2 = leds_M2;
        putInt("leds_M2", leds_M2);
    }

    public int getleds_M2() {
        return leds_M2;
    }
    
    public static int getMinleds_M2() {
        return 0;
    }

    public static int getMaxleds_M2() {
        return 15;
    }

/*    public void setPI_bank_select_M2(final int PI_bank_select_M2) {
        this.PI_bank_select_M2 = PI_bank_select_M2;
        putInt("PI_bank_select_M2", PI_bank_select_M2);
    }

    public int getPI_bank_select_M2() {
        return PI_bank_select_M2;
    }

    public static int getMinPI_bank_select_M2() {
        return 0;
    }

    public static int getMaxPI_bank_select_M2() {
        return 4;
    }*/
    
    /*public void setPD_bank_select_M2(final int PD_bank_select_M2) {
        this.PD_bank_select_M2 = PD_bank_select_M2;
        putInt("PD_bank_select_M2", PD_bank_select_M2);
    }

    public int getPD_bank_select_M2() {
        return PD_bank_select_M2;
    }

    public static int getMinPD_bank_select_M2() {
        return 0;
    }

    public static int getMaxPD_bank_select_M2() {
        return 4;
    }*/
    
    /*public void setEI_bank_select_M2(final int EI_bank_select_M2) {
        this.EI_bank_select_M2 = EI_bank_select_M2;
        putInt("EI_bank_select_M2", EI_bank_select_M2);
    }

    public int getEI_bank_select_M2() {
        return EI_bank_select_M2;
    }

    public static int getMinEI_bank_select_M2() {
        return 0;
    }

    public static int getMaxEI_bank_select_M2() {
        return 4;
    }*/
    
    /*public void setPI_FD_bank0_12bits_M2(final int PI_FD_bank0_12bits_M2) {
        this.PI_FD_bank0_12bits_M2 = PI_FD_bank0_12bits_M2;
        putInt("PI_FD_bank0_12bits_M2", PI_FD_bank0_12bits_M2);
    }

    public int getPI_FD_bank0_12bits_M2() {
        return PI_FD_bank0_12bits_M2;
    }

    public static int getMinPI_FD_bank0_12bits_M2() {
        return 0;
    }

    public static int getMaxPI_FD_bank0_12bits_M2() {
        return (65535);
    }*/

    /*public void setPI_FD_bank1_14bits_M2(final int PI_FD_bank1_14bits_M2) {
        this.PI_FD_bank1_14bits_M2 = PI_FD_bank1_14bits_M2;
        putInt("PI_FD_bank1_14bits_M2", PI_FD_bank1_14bits_M2);
    }

    public int getPI_FD_bank1_14bits_M2() {
        return PI_FD_bank1_14bits_M2;
    }

    public static int getMinPI_FD_bank1_14bits_M2() {
        return 0;
    }

    public static int getMaxPI_FD_bank1_14bits_M2() {
        return (65535);
    }*/

    /*public void setPI_FD_bank2_16bits_M2(final int PI_FD_bank2_16bits_M2) {
        this.PI_FD_bank2_16bits_M2 = PI_FD_bank2_16bits_M2;
        putInt("PI_FD_bank2_16bits_M2", PI_FD_bank2_16bits_M2);
    }

    public int getPI_FD_bank2_16bits_M2() {
        return PI_FD_bank2_16bits_M2;
    }

    public static int getMinPI_FD_bank2_16bits_M2() {
        return 0;
    }

    public static int getMaxPI_FD_bank2_16bits_M2() {
        return (65535);
    }*/

    public void setPI_FD_bank3_18bits_M2(final int PI_FD_bank3_18bits_M2) {
        this.PI_FD_bank3_18bits_M2 = PI_FD_bank3_18bits_M2;
        putInt("PI_FD_bank3_18bits_M2", PI_FD_bank3_18bits_M2);
    }

    public int getPI_FD_bank3_18bits_M2() {
        return PI_FD_bank3_18bits_M2;
    }

    public static int getMinPI_FD_bank3_18bits_M2() {
        return 0;
    }

    public static int getMaxPI_FD_bank3_18bits_M2() {
        return (65535);
    }

    /*public void setEI_FD_bank0_12bits_M2(final int EI_FD_bank0_12bits_M2) {
        this.EI_FD_bank0_12bits_M2 = EI_FD_bank0_12bits_M2;
        putInt("EI_FD_bank0_12bits_M2", EI_FD_bank0_12bits_M2);
    }

    public int getEI_FD_bank0_12bits_M2() {
        return EI_FD_bank0_12bits_M2;
    }

    public static int getMinEI_FD_bank0_12bits_M2() {
        return 0;
    }

    public static int getMaxEI_FD_bank0_12bits_M2() {
        return (65535);
    }*/

    /*public void setEI_FD_bank1_14bits_M2(final int EI_FD_bank1_14bits_M2) {
        this.EI_FD_bank1_14bits_M2 = EI_FD_bank1_14bits_M2;
        putInt("EI_FD_bank1_14bits_M2", EI_FD_bank1_14bits_M2);
    }

    public int getEI_FD_bank1_14bits_M2() {
        return EI_FD_bank1_14bits_M2;
    }

    public static int getMinEI_FD_bank1_14bits_M2() {
        return 0;
    }

    public static int getMaxEI_FD_bank1_14bits_M2() {
        return (65535);
    }*/

    /*public void setEI_FD_bank2_16bits_M2(final int EI_FD_bank2_16bits_M2) {
        this.EI_FD_bank2_16bits_M2 = EI_FD_bank2_16bits_M2;
        putInt("EI_FD_bank2_16bits_M2", EI_FD_bank2_16bits_M2);
    }

    public int getEI_FD_bank2_16bits_M2() {
        return EI_FD_bank2_16bits_M2;
    }

    public static int getMinEI_FD_bank2_16bits_M2() {
        return 0;
    }

    public static int getMaxEI_FD_bank2_16bits_M2() {
        return (65535);
    }*/

    public void setEI_FD_bank3_18bits_M2(final int EI_FD_bank3_18bits_M2) {
        this.EI_FD_bank3_18bits_M2 = EI_FD_bank3_18bits_M2;
        putInt("EI_FD_bank3_18bits_M2", EI_FD_bank3_18bits_M2);
    }

    public int getEI_FD_bank3_18bits_M2() {
        return EI_FD_bank3_18bits_M2;
    }

    public static int getMinEI_FD_bank3_18bits_M2() {
        return 0;
    }

    public static int getMaxEI_FD_bank3_18bits_M2() {
        return (65535);
    }

    /*public void setPD_FD_bank0_16bits_M2(final int PD_FD_bank0_16bits_M2) {
        this.PD_FD_bank0_16bits_M2 = PD_FD_bank0_16bits_M2;
        putInt("PD_FD_bank0_16bits_M2", PD_FD_bank0_16bits_M2);
    }

    public int getPD_FD_bank0_16bits_M2() {
        return PD_FD_bank0_16bits_M2;
    }

    public static int getMinPD_FD_bank0_16bits_M2() {
        return 0;
    }

    public static int getMaxPD_FD_bank0_16bits_M2() {
        return (65535);
    }*/

    /*public void setPD_FD_bank1_18bits_M2(final int PD_FD_bank1_18bits_M2) {
        this.PD_FD_bank1_18bits_M2 = PD_FD_bank1_18bits_M2;
        putInt("PD_FD_bank1_18bits_M2", PD_FD_bank1_18bits_M2);
    }

    public int getID_FD_bank1_18bits_M2() {
        return PD_FD_bank1_18bits_M2;
    }

    public static int getMinPD_FD_bank1_18bits_M2() {
        return 0;
    }

    public static int getMaxPD_FD_bank1_18bits_M2() {
        return (65535);
    }*/

    /*public void setPD_FD_bank2_20bits_M2(final int PD_FD_bank2_20bits_M2) {
        this.PD_FD_bank2_20bits_M2 = PD_FD_bank2_20bits_M2;
        putInt("PD_FD_bank2_20bits_M2", PD_FD_bank2_20bits_M2);
    }

    public int getPD_FD_bank2_20bits_M2() {
        return PD_FD_bank2_20bits_M2;
    }

    public static int getMinPD_FD_bank2_20bits_M2() {
        return 0;
    }

    public static int getMaxPD_FD_bank2_20bits_M2() {
        return (65535);
    }*/

    public void setPD_FD_bank3_22bits_M2(final int PD_FD_bank3_22bits_M2) {
        this.PD_FD_bank3_22bits_M2 = PD_FD_bank3_22bits_M2;
        putInt("PD_FD_bank3_22bits_M2", PD_FD_bank3_22bits_M2);
    }

    public int getPD_FD_bank3_22bits_M2() {
        return PD_FD_bank3_22bits_M2;
    }

    public static int getMinPD_FD_bank3_22bits_M2() {
        return 0;
    }

    public static int getMaxPD_FD_bank3_22bits_M2() {
        return (65535);
    }

    public void setSpikeExpansor_M2(final int SpikeExpansor_M2) {
        this.SpikeExpansor_M2 = SpikeExpansor_M2;
        putInt("SpikeExpansor_M2", SpikeExpansor_M2);
    }

    public int getSpikeExpansor_M2() {
        return SpikeExpansor_M2;
    }

    public static int getMinSpikeExpansor_M2() {
        return 0;
    }

    public static int getMaxSpikeExpansor_M2() {
        return (65535);
    }

    public void setRef_M2(final int Ref_M2) {
        this.Ref_M2 = Ref_M2;
        putInt("Ref_M2", Ref_M2);
    }

    public int getRef_M2() {
        return Ref_M2;
    }

    public static int getMinRef_M2() {
        return 0;
    }

    public static int getMaxRef_M2() {
        return (65535);
    }


    // M3 parameters
    public void setleds_M3(final int leds_M3) {
        this.leds_M3 = leds_M3;
        putInt("leds_M3", leds_M3);
    }

    public int getleds_M3() {
        return leds_M3;
    }
    
    public static int getMinleds_M3() {
        return 0;
    }

    public static int getMaxleds_M3() {
        return 15;
    }

 /*   public void setPI_bank_select_M3(final int PI_bank_select_M3) {
        this.PI_bank_select_M3 = PI_bank_select_M3;
        putInt("PI_bank_select_M3", PI_bank_select_M3);
    }

    public int getPI_bank_select_M3() {
        return PI_bank_select_M3;
    }

    public static int getMinPI_bank_select_M3() {
        return 0;
    }

    public static int getMaxPI_bank_select_M3() {
        return 4;
    }*/
    
    /*public void setPD_bank_select_M3(final int PD_bank_select_M3) {
        this.PD_bank_select_M3 = PD_bank_select_M3;
        putInt("PD_bank_select_M3", PD_bank_select_M3);
    }

    public int getPD_bank_select_M3() {
        return PD_bank_select_M3;
    }

    public static int getMinPD_bank_select_M3() {
        return 0;
    }

    public static int getMaxPD_bank_select_M3() {
        return 3;
    }*/
    
    /*public void setPI_FD_bank0_12bits_M3(final int PI_FD_bank0_12bits_M3) {
        this.PI_FD_bank0_12bits_M3 = PI_FD_bank0_12bits_M3;
        putInt("PI_FD_bank0_12bits_M3", PI_FD_bank0_12bits_M3);
    }

    public int getPI_FD_bank0_12bits_M3() {
        return PI_FD_bank0_12bits_M3;
    }

    public static int getMinPI_FD_bank0_12bits_M3() {
        return 0;
    }

    public static int getMaxPI_FD_bank0_12bits_M3() {
        return (65535);
    }*/

    /*public void setPI_FD_bank1_14bits_M3(final int PI_FD_bank1_14bits_M3) {
        this.PI_FD_bank1_14bits_M3 = PI_FD_bank1_14bits_M3;
        putInt("PI_FD_bank1_14bits_M3", PI_FD_bank1_14bits_M3);
    }

    public int getPI_FD_bank1_14bits_M3() {
        return PI_FD_bank1_14bits_M3;
    }

    public static int getMinPI_FD_bank1_14bits_M3() {
        return 0;
    }

    public static int getMaxPI_FD_bank1_14bits_M3() {
        return (65535);
    }*/

    /*public void setPI_FD_bank2_16bits_M3(final int PD_FD_bank2_16bits_M3) {
        this.PI_FD_bank2_16bits_M3 = PD_FD_bank2_16bits_M3;
        putInt("PI_FD_bank2_16bits_M3", PD_FD_bank2_16bits_M3);
    }

    public int getPI_FD_bank2_16bits_M3() {
        return PI_FD_bank2_16bits_M3;
    }

    public static int getMinPI_FD_bank2_16bits_M3() {
        return 0;
    }

    public static int getMaxPI_FD_bank2_16bits_M3() {
        return (65535);
    }*/

    public void setPI_FD_bank3_18bits_M3(final int PI_FD_bank3_18bits_M3) {
        this.PI_FD_bank3_18bits_M3 = PI_FD_bank3_18bits_M3;
        putInt("PI_FD_bank3_18bits_M3", PI_FD_bank3_18bits_M3);
    }

    public int getPI_FD_bank3_18bits_M3() {
        return PI_FD_bank3_18bits_M3;
    }

    public static int getMinPI_FD_bank3_18bits_M3() {
        return 0;
    }

    public static int getMaxPI_FD_bank3_18bits_M3() {
        return (65535);
    }

    /*public void setEI_bank_select_M3(final int EI_bank_select_M3) {
        this.EI_bank_select_M3 = EI_bank_select_M3;
        putInt("EI_bank_select_M3", EI_bank_select_M3);
    }

    public int getEI_bank_select_M3() {
        return EI_bank_select_M3;
    }

    public static int getMinEI_bank_select_M3() {
        return 0;
    }

    public static int getMaxEI_bank_select_M3() {
        return 3;
    }*/
    
    /*public void setEI_FD_bank0_12bits_M3(final int EI_FD_bank0_12bits_M3) {
        this.EI_FD_bank0_12bits_M3 = EI_FD_bank0_12bits_M3;
        putInt("EI_FD_bank0_12bits_M3", EI_FD_bank0_12bits_M3);
    }

    public int getEI_FD_bank0_12bits_M3() {
        return EI_FD_bank0_12bits_M3;
    }

    public static int getMinEI_FD_bank0_12bits_M3() {
        return 0;
    }

    public static int getMaxEI_FD_bank0_12bits_M3() {
        return (65535);
    }*/

    /*public void setEI_FD_bank1_14bits_M3(final int EI_FD_bank1_14bits_M3) {
        this.EI_FD_bank1_14bits_M3 = EI_FD_bank1_14bits_M3;
        putInt("EI_FD_bank1_14bits_M3", EI_FD_bank1_14bits_M3);
    }

    public int getEI_FD_bank1_14bits_M3() {
        return EI_FD_bank1_14bits_M3;
    }

    public static int getMinEI_FD_bank1_14bits_M3() {
        return 0;
    }

    public static int getMaxEI_FD_bank1_14bits_M3() {
        return (65535);
    }*/

    /*public void setEI_FD_bank2_16bits_M3(final int EI_FD_bank2_16bits_M3) {
        this.EI_FD_bank2_16bits_M3 = EI_FD_bank2_16bits_M3;
        putInt("EI_FD_bank2_16bits_M3", EI_FD_bank2_16bits_M3);
    }

    public int getEI_FD_bank2_16bits_M3() {
        return EI_FD_bank2_16bits_M3;
    }

    public static int getMinEI_FD_bank2_16bits_M3() {
        return 0;
    }

    public static int getMaxEI_FD_bank2_16bits_M3() {
        return (65535);
    }*/

    public void setEI_FD_bank3_18bits_M3(final int EI_FD_bank3_18bits_M3) {
        this.EI_FD_bank3_18bits_M3 = EI_FD_bank3_18bits_M3;
        putInt("EI_FD_bank3_18bits_M3", EI_FD_bank3_18bits_M3);
    }

    public int getEI_FD_bank3_18bits_M3() {
        return EI_FD_bank3_18bits_M3;
    }

    public static int getMinEI_FD_bank3_18bits_M3() {
        return 0;
    }

    public static int getMaxEI_FD_bank3_18bits_M3() {
        return (65535);
    }

    /*public void setPD_FD_bank0_16bits_M3(final int PD_FD_bank0_16bits_M3) {
        this.PD_FD_bank0_16bits_M3 = PD_FD_bank0_16bits_M3;
        putInt("PD_FD_bank0_16bits_M3", PD_FD_bank0_16bits_M3);
    }

    public int getPD_FD_bank0_16bits_M3() {
        return PD_FD_bank0_16bits_M3;
    }

    public static int getMinPD_FD_bank0_16bits_M3() {
        return 0;
    }

    public static int getMaxPD_FD_bank0_16bits_M3() {
        return (65535);
    }*/

    /*public void setPD_FD_bank1_18bits_M3(final int PD_FD_bank1_18bits_M3) {
        this.PD_FD_bank1_18bits_M3 = PD_FD_bank1_18bits_M3;
        putInt("PD_FD_bank1_18bits_M3", PD_FD_bank1_18bits_M3);
    }

    public int getPD_FD_bank1_18bits_M3() {
        return PD_FD_bank1_18bits_M3;
    }

    public static int getMinPD_FD_bank1_18bits_M3() {
        return 0;
    }

    public static int getMaxPD_FD_bank1_18bits_M3() {
        return (65535);
    }*/

    /*public void setPD_FD_bank2_20bits_M3(final int PD_FD_bank2_20bits_M3) {
        this.PD_FD_bank2_20bits_M3 = PD_FD_bank2_20bits_M3;
        putInt("PD_FD_bank2_20bits_M3", PD_FD_bank2_20bits_M3);
    }

    public int getPD_FD_bank2_20bits_M3() {
        return PD_FD_bank2_20bits_M3;
    }

    public static int getMinPD_FD_bank2_20bits_M3() {
        return 0;
    }

    public static int getMaxPD_FD_bank2_20bits_M3() {
        return (65535);
    }*/

    public void setPD_FD_bank3_22bits_M3(final int PD_FD_bank3_22bits_M3) {
        this.PD_FD_bank3_22bits_M3 = PD_FD_bank3_22bits_M3;
        putInt("PD_FD_bank3_22bits_M3", PD_FD_bank3_22bits_M3);
    }

    public int getPD_FD_bank3_22bits_M3() {
        return PD_FD_bank3_22bits_M3;
    }

    public static int getMinPD_FD_bank3_22bits_M3() {
        return 0;
    }

    public static int getMaxPD_FD_bank3_22bits_M3() {
        return (65535);
    }

    public void setSpikeExpansor_M3(final int SpikeExpansor_M3) {
        this.SpikeExpansor_M3 = SpikeExpansor_M3;
        putInt("SpikeExpansor_M3", SpikeExpansor_M3);
    }

    public int getSpikeExpansor_M3() {
        return SpikeExpansor_M3;
    }

    public static int getMinSpikeExpansor_M3() {
        return 0;
    }

    public static int getMaxSpikeExpansor_M3() {
        return (65535);
    }

    public void setRef_M3(final int Ref_M3) {
        this.Ref_M3 = Ref_M3;
        putInt("Ref_M3", Ref_M3);
    }

    public int getRef_M3() {
        return Ref_M3;
    }

    public static int getMinRef_M3() {
        return 0;
    }

    public static int getMaxRef_M3() {
        return (65535);
    }
    
    // M4 parameters
    public void setleds_M4(final int leds_M4) {
        this.leds_M4 = leds_M4;
        putInt("leds_M4", leds_M4);
    }

    public int getleds_M4() {
        return leds_M4;
    }
    
    public static int getMinleds_M4() {
        return 0;
    }

    public static int getMaxleds_M4() {
        return 15;
    }

/*    public void setPI_bank_select_M4(final int PI_bank_select_M4) {
        this.PI_bank_select_M4 = PI_bank_select_M4;
        putInt("PI_bank_select_M4", PI_bank_select_M4);
    }

    public int getPI_bank_select_M4() {
        return PI_bank_select_M4;
    }

    public static int getMinPI_bank_select_M4() {
        return 0;
    }

    public static int getMaxPI_bank_select_M4() {
        return 3;
    }*/
    
    /*public void setPD_bank_select_M4(final int PD_bank_select_M4) {
        this.PD_bank_select_M4 = PD_bank_select_M4;
        putInt("PD_bank_select_M4", PD_bank_select_M4);
    }

    public int getPD_bank_select_M4() {
        return PD_bank_select_M4;
    }

    public static int getMinPD_bank_select_M4() {
        return 0;
    }

    public static int getMaxPD_bank_select_M4() {
        return 4;
    }*/
    
    /*public void setPI_FD_bank0_12bits_M4(final int PI_FD_bank0_12bits_M4) {
        this.PI_FD_bank0_12bits_M4 = PI_FD_bank0_12bits_M4;
        putInt("PI_FD_bank0_12bits_M4", PI_FD_bank0_12bits_M4);
    }

    public int getPI_FD_bank0_12bits_M4() {
        return PI_FD_bank0_12bits_M4;
    }

    public static int getMinPI_FD_bank0_12bits_M4() {
        return 0;
    }

    public static int getMaxPI_FD_bank0_12bits_M4() {
        return (65535);
    }*/

    /*public void setPI_FD_bank1_14bits_M4(final int PD_FD_bank1_14bits_M4) {
        this.PI_FD_bank1_14bits_M4 = PD_FD_bank1_14bits_M4;
        putInt("PI_FD_bank1_14bits_M4", PD_FD_bank1_14bits_M4);
    }

    public int getPI_FD_bank1_14bits_M4() {
        return PI_FD_bank1_14bits_M4;
    }

    public static int getMinPI_FD_bank1_14bits_M4() {
        return 0;
    }

    public static int getMaxPI_FD_bank1_14bits_M4() {
        return (65535);
    }*/

    /*public void setPI_FD_bank2_16bits_M4(final int PI_FD_bank2_16bits_M4) {
        this.PI_FD_bank2_16bits_M4 = PI_FD_bank2_16bits_M4;
        putInt("PI_FD_bank2_16bits_M4", PI_FD_bank2_16bits_M4);
    }

    public int getPI_FD_bank2_16bits_M4() {
        return PI_FD_bank2_16bits_M4;
    }

    public static int getMinPI_FD_bank2_16bits_M4() {
        return 0;
    }

    public static int getMaxPI_FD_bank2_16bits_M4() {
        return (65535);
    }*/

    public void setPI_FD_bank3_18bits_M4(final int PI_FD_bank3_18bits_M4) {
        this.PI_FD_bank3_18bits_M4 = PI_FD_bank3_18bits_M4;
        putInt("PI_FD_bank3_18bits_M4", PI_FD_bank3_18bits_M4);
    }

    public int getPI_FD_bank3_18bits_M4() {
        return PI_FD_bank3_18bits_M4;
    }

    public static int getMinPI_FD_bank3_18bits_M4() {
        return 0;
    }

    public static int getMaxPI_FD_bank3_18bits_M4() {
        return (65535);
    }

    /*public void setEI_bank_select_M4(final int EI_bank_select_M4) {
        this.EI_bank_select_M4 = EI_bank_select_M4;
        putInt("EI_bank_select_43", EI_bank_select_M4);
    }

    public int getEI_bank_select_M4() {
        return EI_bank_select_M4;
    }

    public static int getMinEI_bank_select_M4() {
        return 0;
    }

    public static int getMaxEI_bank_select_M4() {
        return 4;
    }*/
    
    /*public void setEI_FD_bank0_12bits_M4(final int EI_FD_bank0_12bits_M4) {
        this.EI_FD_bank0_12bits_M4 = EI_FD_bank0_12bits_M4;
        putInt("EI_FD_bank0_12bits_M4", EI_FD_bank0_12bits_M4);
    }

    public int getEI_FD_bank0_12bits_M4() {
        return EI_FD_bank0_12bits_M4;
    }

    public static int getMinEI_FD_bank0_12bits_M4() {
        return 0;
    }

    public static int getMaxEI_FD_bank0_12bits_M4() {
        return (65535);
    }*/

    /*public void setEI_FD_bank1_14bits_M4(final int EI_FD_bank1_14bits_M4) {
        this.EI_FD_bank1_14bits_M4 = EI_FD_bank1_14bits_M4;
        putInt("EI_FD_bank1_14bits_M4", EI_FD_bank1_14bits_M4);
    }

    public int getEI_FD_bank1_14bits_M4() {
        return EI_FD_bank1_14bits_M4;
    }

    public static int getMinEI_FD_bank1_14bits_M4() {
        return 0;
    }

    public static int getMaxEI_FD_bank1_14bits_M4() {
        return (65535);
    }*/

    /*public void setEI_FD_bank2_16bits_M4(final int EI_FD_bank2_16bits_M4) {
        this.EI_FD_bank2_16bits_M4 = EI_FD_bank2_16bits_M4;
        putInt("EI_FD_bank2_16bits_M4", EI_FD_bank2_16bits_M4);
    }

    public int getEI_FD_bank2_16bits_M4() {
        return EI_FD_bank2_16bits_M4;
    }

    public static int getMinEI_FD_bank2_16bits_M4() {
        return 0;
    }

    public static int getMaxEI_FD_bank2_16bits_M4() {
        return (65535);
    }*/

    public void setEI_FD_bank3_18bits_M4(final int EI_FD_bank3_18bits_M4) {
        this.EI_FD_bank3_18bits_M4 = EI_FD_bank3_18bits_M4;
        putInt("EI_FD_bank3_18bits_M4", EI_FD_bank3_18bits_M4);
    }

    public int getEI_FD_bank3_18bits_M4() {
        return EI_FD_bank3_18bits_M4;
    }

    public static int getMinEI_FD_bank3_18bits_M4() {
        return 0;
    }

    public static int getMaxEI_FD_bank3_18bits_M4() {
        return (65535);
    }

    /*public void setPD_FD_bank0_16bits_M4(final int PD_FD_bank0_16bits_M4) {
        this.PD_FD_bank0_16bits_M4 = PD_FD_bank0_16bits_M4;
        putInt("PD_FD_bank0_16bits_M4", PD_FD_bank0_16bits_M4);
    }

    public int getPD_FD_bank0_16bits_M4() {
        return PD_FD_bank0_16bits_M4;
    }

    public static int getMinPD_FD_bank0_16bits_M4() {
        return 0;
    }

    public static int getMaxPD_FD_bank0_16bits_M4() {
        return (65535);
    }*/

    /*public void setPD_FD_bank1_18bits_M4(final int PD_FD_bank1_18bits_M4) {
        this.PD_FD_bank1_18bits_M4 = PD_FD_bank1_18bits_M4;
        putInt("PD_FD_bank1_18bits_M4", PD_FD_bank1_18bits_M4);
    }

    public int getPD_FD_bank1_18bits_M4() {
        return PD_FD_bank1_18bits_M4;
    }

    public static int getMinPD_FD_bank1_18bits_M4() {
        return 0;
    }

    public static int getMaxPD_FD_bank1_18bits_M4() {
        return (65535);
    }*/

    /*public void setPD_FD_bank2_20bits_M4(final int PD_FD_bank2_20bits_M4) {
        this.PD_FD_bank2_20bits_M4 = PD_FD_bank2_20bits_M4;
        putInt("PD_FD_bank2_20bits_M4", PD_FD_bank2_20bits_M4);
    }

    public int getID_FD_bank2_20bits_M4() {
        return PD_FD_bank2_20bits_M4;
    }

    public static int getMinPD_FD_bank2_20bits_M4() {
        return 0;
    }

    public static int getMaxPD_FD_bank2_20bits_M4() {
        return (65535);
    }*/

    public void setPD_FD_bank3_22bits_M4(final int PD_FD_bank3_22bits_M4) {
        this.PD_FD_bank3_22bits_M4 = PD_FD_bank3_22bits_M4;
        putInt("PD_FD_bank3_22bits_M4", PD_FD_bank3_22bits_M4);
    }

    public int getPD_FD_bank3_22bits_M4() {
        return PD_FD_bank3_22bits_M4;
    }

    public static int getMinPD_FD_bank3_22bits_M4() {
        return 0;
    }

    public static int getMaxPD_FD_bank3_22bits_M4() {
        return (65535);
    }

    public void setSpikeExpansor_M4(final int SpikeExpansor_M4) {
        this.SpikeExpansor_M4 = SpikeExpansor_M4;
        putInt("SpikeExpansor_M4", SpikeExpansor_M4);
    }

    public int getSpikeExpansor_M4() {
        return SpikeExpansor_M4;
    }

    public static int getMinSpikeExpansor_M4() {
        return 0;
    }

    public static int getMaxSpikeExpansor_M4() {
        return (65535);
    }

    public void setRef_M4(final int Ref_M4) {
        this.Ref_M4 = Ref_M4;
        putInt("Ref_M4", Ref_M4);
    }

    public int getRef_M4() {
        return Ref_M4;
    }

    public static int getMinRef_M4() {
        return 0;
    }

    public static int getMaxRef_M4() {
        return (65535);
    }
    
  
    synchronized public void doConfigureInit() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int sendDecayTimeMs = getInt("DecayTimeMs", 0);// * CLOCK_SPEED; //* 10 ^ (-6));
        final int sendTauNDecay = getInt("TauNDecay", 0);// / (CLOCK_SPEED * 10 ^ (-6));

        if (AERRobot_USBEnable)
        {
            for (int i = 0; i <= 5; i++) {
            // Send all the OMC configuration.
                sendCommand16((byte) 0, (byte) (0x00),(byte) (0x03), true); //LEDs M1
                sendCommand16((byte) 0x02, (byte) (0x00), (byte) (0x00), true); //Ref M1 0
                sendCommand16((byte) 0x03, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M1
                sendCommand16((byte) 0x04, (byte) ((PI_FD_bank0_12bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M1) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x05, (byte) ((PI_FD_bank1_14bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M1) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x06, (byte) ((PI_FD_bank2_16bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x08, (byte) (0x00), (byte) (0x0f), true); //d banks disabled M1
                sendCommand16((byte) 0x09, (byte) ((PD_FD_bank0_16bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M1) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x0A, (byte) ((PD_FD_bank1_18bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M1) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x0B, (byte) ((PD_FD_bank2_20bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x12, (byte) (0x00), (byte) (0x0), true); //spike expansor M1
                sendCommand16((byte) 0x13, (byte) (0x00), (byte) (0x0f), true); //d banks disabled M1
                sendCommand16((byte) 0x14, (byte) ((EI_FD_bank0_12bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M1) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x15, (byte) ((EI_FD_bank1_14bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M1) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x16, (byte) ((EI_FD_bank2_16bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0, (byte) 0, (byte) 0, false); //LEDs M1 off
                logger.info(String.format("PI_FD_bank0_12bits_M1=%d \t PI_FD_bank1_14bits_M1=%d \t PI_FD_bank2_16bits_M1=%d \t PI_FD_bank3_18bits_M1=%d\n" +
                                          "PD_FD_bank0_16bits_M1=%d \t PD_FD_bank1_18bits_M1=%d \t PD_FD_bank2_20bits_M1=%d \t PD_FD_bank3_22bits_M1=%d\n" +
                                          "EI_FD_bank0_12bits_M1=%d \t EI_FD_bank1_14bits_M1=%d \t EI_FD_bank2_16bits_M1=%d \t EI_FD_bank3_18bits_M1=%d\n"
                                         ,PI_FD_bank0_12bits_M1,PI_FD_bank1_14bits_M1,PI_FD_bank2_16bits_M1,PI_FD_bank3_18bits_M1                                         
                                         ,PD_FD_bank0_16bits_M1,PD_FD_bank1_18bits_M1,PD_FD_bank2_20bits_M1,PD_FD_bank3_22bits_M1                                         
                                         ,EI_FD_bank0_12bits_M1,EI_FD_bank1_14bits_M1,EI_FD_bank2_16bits_M1,EI_FD_bank3_18bits_M1));
                
                sendCommand16((byte) 0x20, (byte) (0x00),(byte) (0x03), true); //LEDs M2
                sendCommand16((byte) 0x22, (byte) (0x00), (byte) (0x00), true); //Ref M2 0
                sendCommand16((byte) 0x23, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M2
                sendCommand16((byte) 0x24, (byte) ((PI_FD_bank0_12bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M2) & 0xFF), true); //FD I&G bank 0 M2
                sendCommand16((byte) 0x25, (byte) ((PI_FD_bank1_14bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M2) & 0xFF), true); //FD I&G bank 1 M2
                sendCommand16((byte) 0x26, (byte) ((PI_FD_bank2_16bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M2) & 0xFF), true); //FD I&G bank 2 M2
                sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
                sendCommand16((byte) 0x28, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M2
                sendCommand16((byte) 0x29, (byte) ((PD_FD_bank0_16bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M2) & 0xFF), true); //FD I&G bank 0 M2
                sendCommand16((byte) 0x2A, (byte) ((PD_FD_bank1_18bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M2) & 0xFF), true); //FD I&G bank 1 M2
                sendCommand16((byte) 0x2B, (byte) ((PD_FD_bank2_20bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M2) & 0xFF), true); //FD I&G bank 2 M2
                sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M2
                sendCommand16((byte) 0x32, (byte) (0x00), (byte) (0x0), true); //spike expansor M2
                sendCommand16((byte) 0x33, (byte) (0x00), (byte) (0x0f), true); //d banks disabled M1
                sendCommand16((byte) 0x34, (byte) ((EI_FD_bank0_12bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M2) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x35, (byte) ((EI_FD_bank1_14bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M2) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x36, (byte) ((EI_FD_bank2_16bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M2) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x20, (byte) 0, (byte) 0, false); //LEDs M2 off

                logger.info(String.format("PI_FD_bank0_12bits_M2=%d \t PI_FD_bank1_14bits_M2=%d \t PI_FD_bank2_16bits_M2=%d \t PI_FD_bank3_18bits_M2=%d\n" +
                                          "PD_FD_bank0_16bits_M2=%d \t PD_FD_bank1_18bits_M2=%d \t PD_FD_bank2_20bits_M2=%d \t PD_FD_bank3_22bits_M2=%d\n" +
                                          "EI_FD_bank0_12bits_M2=%d \t EI_FD_bank1_14bits_M2=%d \t EI_FD_bank2_16bits_M2=%d \t EI_FD_bank3_18bits_M2=%d\n"
                                         ,PI_FD_bank0_12bits_M2,PI_FD_bank1_14bits_M2,PI_FD_bank2_16bits_M2,PI_FD_bank3_18bits_M2                                         
                                         ,PD_FD_bank0_16bits_M2,PD_FD_bank1_18bits_M2,PD_FD_bank2_20bits_M2,PD_FD_bank3_22bits_M2                                         
                                         ,EI_FD_bank0_12bits_M2,EI_FD_bank1_14bits_M2,EI_FD_bank2_16bits_M2,EI_FD_bank3_18bits_M2));
                
                sendCommand16((byte) 0x40, (byte) (0x00),(byte) (0x03), true); //LEDs M3
                sendCommand16((byte) 0x42, (byte) (0x00), (byte) (0x00), true); //Ref M3 0
                sendCommand16((byte) 0x43, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M3
                sendCommand16((byte) 0x44, (byte) ((PI_FD_bank0_12bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M3) & 0xFF), true); //FD I&G bank 0 M3
                sendCommand16((byte) 0x45, (byte) ((PI_FD_bank1_14bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M3) & 0xFF), true); //FD I&G bank 1 M3
                sendCommand16((byte) 0x46, (byte) ((PI_FD_bank2_16bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M3) & 0xFF), true); //FD I&G bank 2 M3
                sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
                sendCommand16((byte) 0x48, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M3
                sendCommand16((byte) 0x49, (byte) ((PD_FD_bank0_16bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M3) & 0xFF), true); //FD I&G bank 0 M3
                sendCommand16((byte) 0x4A, (byte) ((PD_FD_bank1_18bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M3) & 0xFF), true); //FD I&G bank 1 M3
                sendCommand16((byte) 0x4B, (byte) ((PD_FD_bank2_20bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M3) & 0xFF), true); //FD I&G bank 2 M3
                sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M3
                sendCommand16((byte) 0x52, (byte) (0x00), (byte) (0x0), true); //spike expansor M3
                sendCommand16((byte) 0x53, (byte) (0x00), (byte) (0x0f), true); //d banks disabled M1
                sendCommand16((byte) 0x54, (byte) ((EI_FD_bank0_12bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M3) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x55, (byte) ((EI_FD_bank1_14bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M3) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x56, (byte) ((EI_FD_bank2_16bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M3) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x40, (byte) 0, (byte) 0, false); //LEDs M3 off

                logger.info(String.format("PI_FD_bank0_12bits_M3=%d \t PI_FD_bank1_14bits_M3=%d \t PI_FD_bank2_16bits_M3=%d \t PI_FD_bank3_18bits_M3=%d\n" +
                                          "PD_FD_bank0_16bits_M3=%d \t PD_FD_bank1_18bits_M3=%d \t PD_FD_bank2_20bits_M3=%d \t PD_FD_bank3_22bits_M3=%d\n" +
                                          "EI_FD_bank0_12bits_M3=%d \t EI_FD_bank1_14bits_M3=%d \t EI_FD_bank2_16bits_M3=%d \t EI_FD_bank3_18bits_M3=%d\n"
                                         ,PI_FD_bank0_12bits_M3,PI_FD_bank1_14bits_M3,PI_FD_bank2_16bits_M3,PI_FD_bank3_18bits_M3                                         
                                         ,PD_FD_bank0_16bits_M3,PD_FD_bank1_18bits_M3,PD_FD_bank2_20bits_M3,PD_FD_bank3_22bits_M3                                         
                                         ,EI_FD_bank0_12bits_M3,EI_FD_bank1_14bits_M3,EI_FD_bank2_16bits_M3,EI_FD_bank3_18bits_M3));
                
                sendCommand16((byte) 0x60, (byte) (0x00),(byte) (0x03), true); //LEDs M4
                sendCommand16((byte) 0x62, (byte) (0x00), (byte) (0x00), true); //Ref M4 0
                sendCommand16((byte) 0x63, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M4
                sendCommand16((byte) 0x64, (byte) ((PI_FD_bank0_12bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M4) & 0xFF), true); //FD I&G bank 0 M4
                sendCommand16((byte) 0x65, (byte) ((PI_FD_bank1_14bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M4) & 0xFF), true); //FD I&G bank 1 M4
                sendCommand16((byte) 0x66, (byte) ((PI_FD_bank2_16bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M4) & 0xFF), true); //FD I&G bank 2 M4
                sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
                sendCommand16((byte) 0x68, (byte) (0x00), (byte) (0x0f), true); //I banks disabled M4
                sendCommand16((byte) 0x69, (byte) ((PD_FD_bank0_16bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M4) & 0xFF), true); //FD I&G bank 0 M4
                sendCommand16((byte) 0x6A, (byte) ((PD_FD_bank1_18bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M4) & 0xFF), true); //FD I&G bank 1 M4
                sendCommand16((byte) 0x6B, (byte) ((PD_FD_bank2_20bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M4) & 0xFF), true); //FD I&G bank 2 M4
                sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
                sendCommand16((byte) 0x72, (byte) (0x00), (byte) (0x0), true); //spike expansor M4
                sendCommand16((byte) 0x73, (byte) (0x00), (byte) (0x0f), true); //d banks disabled M1
                sendCommand16((byte) 0x74, (byte) ((EI_FD_bank0_12bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M4) & 0xFF), true); //FD I&G bank 0 M1
                sendCommand16((byte) 0x75, (byte) ((EI_FD_bank1_14bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M4) & 0xFF), true); //FD I&G bank 1 M1
                sendCommand16((byte) 0x76, (byte) ((EI_FD_bank2_16bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M4) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x60, (byte) 0, (byte) 0, false); //LEDs M4 off

                logger.info(String.format("PI_FD_bank0_12bits_M4=%d \t PI_FD_bank1_14bits_M4=%d \t PI_FD_bank2_16bits_M4=%d \t PI_FD_bank3_18bits_M4=%d\n" +
                                          "PD_FD_bank0_16bits_M4=%d \t PD_FD_bank1_18bits_M4=%d \t PD_FD_bank2_20bits_M4=%d \t PD_FD_bank3_22bits_M4=%d\n" +
                                          "EI_FD_bank0_12bits_M4=%d \t EI_FD_bank1_14bits_M4=%d \t EI_FD_bank2_16bits_M4=%d \t EI_FD_bank3_18bits_M4=%d\n"
                                         ,PI_FD_bank0_12bits_M4,PI_FD_bank1_14bits_M4,PI_FD_bank2_16bits_M4,PI_FD_bank3_18bits_M4                                         
                                         ,PD_FD_bank0_16bits_M4,PD_FD_bank1_18bits_M4,PD_FD_bank2_20bits_M4,PD_FD_bank3_22bits_M4                                         
                                         ,EI_FD_bank0_12bits_M4,EI_FD_bank1_14bits_M4,EI_FD_bank2_16bits_M4,EI_FD_bank3_18bits_M4));
                
                System.out.print("Sending USB SPI");
                System.out.println(i);
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doConfigureSPID() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int sendDecayTimeMs = getInt("DecayTimeMs", 0);// * CLOCK_SPEED; //* 10 ^ (-6));
        final int sendTauNDecay = getInt("TauNDecay", 0);// / (CLOCK_SPEED * 10 ^ (-6));

        if (AERRobot_USBEnable)
        {
            for (int i = 0; i <= 5; i++) {
            // Send all the OMC configuration.
        
                sendCommand16((byte) 0, (byte) (0x00),(byte) ((leds_M1) & 0xFF), true); //LEDs M1
                sendCommand16((byte) 0x02, (byte) ((Ref_M1 >>> 8) & 0xFF), (byte) ((Ref_M1) & 0xFF), true); //Ref M1 0
                sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
//                sendCommand16((byte) 0x04, (byte) ((PI_FD_bank0_12bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M1) & 0xFF), true); //FD I&G bank 0 M1
//                sendCommand16((byte) 0x05, (byte) ((PI_FD_bank1_14bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M1) & 0xFF), true); //FD I&G bank 1 M1
//                sendCommand16((byte) 0x06, (byte) ((PI_FD_bank2_16bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
//                sendCommand16((byte) 0x09, (byte) ((PD_FD_bank0_16bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M1) & 0xFF), true); //FD I&G bank 0 M1
//                sendCommand16((byte) 0x0A, (byte) ((PD_FD_bank1_18bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M1) & 0xFF), true); //FD I&G bank 1 M1
//                sendCommand16((byte) 0x0B, (byte) ((PD_FD_bank2_20bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
                sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
//                sendCommand16((byte) 0x14, (byte) ((EI_FD_bank0_12bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M1) & 0xFF), true); //FD I&G bank 0 M1
//                sendCommand16((byte) 0x15, (byte) ((EI_FD_bank1_14bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M1) & 0xFF), true); //FD I&G bank 1 M1
//                sendCommand16((byte) 0x16, (byte) ((EI_FD_bank2_16bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M1) & 0xFF), true); //FD I&G bank 2 M1
                sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
                //sendCommand16((byte) 0, (byte) 0, (byte) 0, false); //LEDs M1 off

                logger.info(String.format("leds_M1=%d \t Ref_M1=%d \t PI_bank_select_M1=%d \t PI_FD_bank3_18bits_M1=%d\n" +
                                          "PD_bank_select_M1=%d \t PD_FD_bank3_22bits_M1=%d \n EI_bank_select_M1=%d\t" +
                                          "EI_FD_bank3_18bits_M1=%d\t SpikeExpansor_M1=%d \n"
                                         ,leds_M1,Ref_M1,PI_bank_select_M1,PI_FD_bank3_18bits_M1                                         
                                         ,PD_bank_select_M1,PD_FD_bank3_22bits_M1,EI_bank_select_M1                                         
                                         ,EI_FD_bank3_18bits_M1,SpikeExpansor_M1));

                sendCommand16((byte) 0x20, (byte) (0x00),(byte) ((leds_M2) & 0xFF), true); //LEDs M2
                sendCommand16((byte) 0x22, (byte) ((Ref_M2 >>> 8) & 0xFF), (byte) ((Ref_M2) & 0xFF), true); //Ref M2 0
                sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M2
//                sendCommand16((byte) 0x24, (byte) ((PI_FD_bank0_12bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M2) & 0xFF), true); //FD I&G bank 0 M2
//                sendCommand16((byte) 0x25, (byte) ((PI_FD_bank1_14bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M2) & 0xFF), true); //FD I&G bank 1 M2
//                sendCommand16((byte) 0x26, (byte) ((PI_FD_bank2_16bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M2) & 0xFF), true); //FD I&G bank 2 M2
                sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
                sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M2
//                sendCommand16((byte) 0x29, (byte) ((PD_FD_bank0_16bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M2) & 0xFF), true); //FD I&G bank 0 M2
//                sendCommand16((byte) 0x2A, (byte) ((PD_FD_bank1_18bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M2) & 0xFF), true); //FD I&G bank 1 M2
//                sendCommand16((byte) 0x2B, (byte) ((PD_FD_bank2_20bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M2) & 0xFF), true); //FD I&G bank 2 M2
                sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M2
                sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M2
                sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M2
//                sendCommand16((byte) 0x34, (byte) ((EI_FD_bank0_12bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M2) & 0xFF), true); //FD I&G bank 0 M2
//                sendCommand16((byte) 0x35, (byte) ((EI_FD_bank1_14bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M2) & 0xFF), true); //FD I&G bank 1 M2
//                sendCommand16((byte) 0x36, (byte) ((EI_FD_bank2_16bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M2) & 0xFF), true); //FD I&G bank 2 M2
                sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
                //sendCommand16((byte) 0x20, (byte) 0, (byte) 0, false); //LEDs M2 off

                logger.info(String.format("leds_M2=%d \t Ref_M2=%d \t PI_bank_select_M2=%d \t PI_FD_bank3_18bits_M2=%d\n" +
                                          "PD_bank_select_M2=%d \t PD_FD_bank3_22bits_M2=%d \n EI_bank_select_M2=%d\t" +
                                          "EI_FD_bank3_18bits_M2=%d\t SpikeExpansor_M2=%d \n"
                                         ,leds_M2,Ref_M2,PI_bank_select_M2,PI_FD_bank3_18bits_M2                                         
                                         ,PD_bank_select_M2,PD_FD_bank3_22bits_M2,EI_bank_select_M2                                         
                                         ,EI_FD_bank3_18bits_M2,SpikeExpansor_M2));
                
                sendCommand16((byte) 0x40, (byte) (0x00),(byte) ((leds_M3) & 0xFF), true); //LEDs M3
                sendCommand16((byte) 0x42, (byte) ((Ref_M3 >>> 8) & 0xFF), (byte) ((Ref_M3) & 0xFF), true); //Ref M3 0
                sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M3
//                sendCommand16((byte) 0x44, (byte) ((PI_FD_bank0_12bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M3) & 0xFF), true); //FD I&G bank 0 M3
//                sendCommand16((byte) 0x45, (byte) ((PI_FD_bank1_14bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M3) & 0xFF), true); //FD I&G bank 1 M3
//                sendCommand16((byte) 0x46, (byte) ((PI_FD_bank2_16bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M3) & 0xFF), true); //FD I&G bank 2 M3
                sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
                sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M3
//                sendCommand16((byte) 0x49, (byte) ((PD_FD_bank0_16bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M3) & 0xFF), true); //FD I&G bank 0 M3
//                sendCommand16((byte) 0x4A, (byte) ((PD_FD_bank1_18bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M3) & 0xFF), true); //FD I&G bank 1 M3
//                sendCommand16((byte) 0x4B, (byte) ((PD_FD_bank2_20bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M3) & 0xFF), true); //FD I&G bank 2 M3
                sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M3
                sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M3
                sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M3
//                sendCommand16((byte) 0x54, (byte) ((EI_FD_bank0_12bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M3) & 0xFF), true); //FD I&G bank 0 M3
//                sendCommand16((byte) 0x55, (byte) ((EI_FD_bank1_14bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M3) & 0xFF), true); //FD I&G bank 1 M3
//                sendCommand16((byte) 0x56, (byte) ((EI_FD_bank2_16bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M3) & 0xFF), true); //FD I&G bank 2 M3
                sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
                //sendCommand16((byte) 0x40, (byte) 0, (byte) 0, false); //LEDs M3 off

                logger.info(String.format("leds_M3=%d \t Ref_M3=%d \t PI_bank_select_M3=%d \t PI_FD_bank3_18bits_M3=%d\n" +
                                          "PD_bank_select_M3=%d \t PD_FD_bank3_22bits_M3=%d \n EI_bank_select_M3=%d\t" +
                                          "EI_FD_bank3_18bits_M3=%d\t SpikeExpansor_M3=%d \n"
                                         ,leds_M3,Ref_M3,PI_bank_select_M3,PI_FD_bank3_18bits_M3                                         
                                         ,PD_bank_select_M3,PD_FD_bank3_22bits_M3,EI_bank_select_M3                                         
                                         ,EI_FD_bank3_18bits_M3,SpikeExpansor_M3));

                sendCommand16((byte) 0x60, (byte) (0x00),(byte) ((leds_M4) & 0xFF), true); //LEDs M4
                sendCommand16((byte) 0x62, (byte) ((Ref_M4 >>> 8) & 0xFF), (byte) ((Ref_M4) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
//                sendCommand16((byte) 0x64, (byte) ((PI_FD_bank0_12bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank0_12bits_M4) & 0xFF), true); //FD I&G bank 0 M4
//                sendCommand16((byte) 0x65, (byte) ((PI_FD_bank1_14bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank1_14bits_M4) & 0xFF), true); //FD I&G bank 1 M4
//                sendCommand16((byte) 0x66, (byte) ((PI_FD_bank2_16bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank2_16bits_M4) & 0xFF), true); //FD I&G bank 2 M4
                sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
                sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
//                sendCommand16((byte) 0x69, (byte) ((PD_FD_bank0_16bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank0_16bits_M4) & 0xFF), true); //FD I&G bank 0 M4
//                sendCommand16((byte) 0x6A, (byte) ((PD_FD_bank1_18bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank1_18bits_M4) & 0xFF), true); //FD I&G bank 1 M4
//                sendCommand16((byte) 0x6B, (byte) ((PD_FD_bank2_20bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank2_20bits_M4) & 0xFF), true); //FD I&G bank 2 M4
                sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
                sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
                sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
//                sendCommand16((byte) 0x74, (byte) ((EI_FD_bank0_12bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank0_12bits_M4) & 0xFF), true); //FD I&G bank 0 M4
//                sendCommand16((byte) 0x75, (byte) ((EI_FD_bank1_14bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank1_14bits_M4) & 0xFF), true); //FD I&G bank 1 M4
//                sendCommand16((byte) 0x76, (byte) ((EI_FD_bank2_16bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank2_16bits_M4) & 0xFF), true); //FD I&G bank 2 M4
                sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
                //sendCommand16((byte) 0x60, (byte) 0, (byte) 0, false); //LEDs M4 off

                logger.info(String.format("leds_M4=%d \t Ref_M4=%d \t PI_bank_select_M4=%d \t PI_FD_bank3_18bits_M4=%d\n" +
                                          "PD_bank_select_M4=%d \t PD_FD_bank3_22bits_M4=%d \n EI_bank_select_M4=%d\t" +
                                          "EI_FD_bank3_18bits_M4=%d\t SpikeExpansor_M4=%d \n"
                                         ,leds_M4,Ref_M4,PI_bank_select_M4,PI_FD_bank3_18bits_M4                                         
                                         ,PD_bank_select_M4,PD_FD_bank3_22bits_M4,EI_bank_select_M4                                         
                                         ,EI_FD_bank3_18bits_M4,SpikeExpansor_M4));

                System.out.print("Sending USB SPI");
                System.out.println(i);
            }
            
            
            
            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");

                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 5000) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),Ref_M1,Read_J1_pos(),Ref_M2,Read_J2_pos(),Ref_M3,Read_J3_pos(),Ref_M4,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }

        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doScanMotor1() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int scanInitValue = getInt("Scan_Init_Value",0);
        final int scanFinalValue = getInt("Scan_Final_Value", 0);
        final int scanStepValue = getInt("Scan_Step_Value",0);
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);
        Logger logger = Logger.getLogger("ScanMotor1Log");  
        FileHandler fh; 
        
        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/Scan1_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Joint1 Scan Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
            
            sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x02, (byte) ((scanInitValue >>> 8) & 0xFF), (byte) ((scanInitValue) & 0xFF), true); //Ref M1 0
//            try {
//                Thread.sleep(1500);
//            } catch (InterruptedException ex) {
//                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//            }
            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");

                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),scanInitValue,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }

            for (int i = scanInitValue; i <= scanFinalValue; i+=scanStepValue) {
                sendCommand16((byte) 0x02, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),i,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
            for (int i = scanFinalValue; i >= scanInitValue; i-=scanStepValue) {
                sendCommand16((byte) 0x02, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while ((now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) now=System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),i,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doScanMotor2() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int scanInitValue = getInt("Scan_Init_Value",0);
        final int scanFinalValue = getInt("Scan_Final_Value", 0);
        final int scanStepValue = getInt("Scan_Step_Value",0);
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);
        Logger logger = Logger.getLogger("ScanMotor2Log");  
        FileHandler fh;  

        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/Scan2_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Joint2 Scan Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  

            sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x28, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x22, (byte) ((scanInitValue >>> 8) & 0xFF), (byte) ((scanInitValue) & 0xFF), true); //Ref M1 0
//            try {
//                Thread.sleep(1500);
//            } catch (InterruptedException ex) {
//                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//            }
              logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");

                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),0,Read_J1_pos(),scanInitValue,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }
                
            //int sensor_J2=0;
            for (int i = scanInitValue; i <= scanFinalValue; i+=scanStepValue) {
                sendCommand16((byte) 0x22, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 2 position ref: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
//                sensor_J2 = read_sensor_J2();
//                System.out.print("Read Sensor J2 position: ");
//                System.out.println(sensor_J2);
                  long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),i,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
            for (int i = scanFinalValue; i >= scanInitValue; i-=scanStepValue) {
                sendCommand16((byte) 0x22, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 2 position: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
//                 sensor_J2 = read_sensor_J2();
//                System.out.print("Read Sensor J2 position: ");
//                System.out.println(sensor_J2);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while ((now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) now=System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),i,Read_J2_pos(),0,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }  
    
    private int read_sensor_J1()
    {
        int sensor_j1=-1;
        for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sensor_j1 = readSensor((byte)0x01);
                if (sensor_j1 >0) {
                   break;
            }
        }
        return sensor_j1;
    }    

    private int read_sensor_J2()
    {
        int sensor_j2=-1;
        for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sensor_j2 = readSensor((byte)0x02);
                if (sensor_j2 >0) {
                   break;
            }
        }
        return sensor_j2;
    }    

    synchronized public void doScanMotor3() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int scanInitValue = getInt("Scan_Init_Value",0);
        final int scanFinalValue = getInt("Scan_Final_Value", 0);
        final int scanStepValue = getInt("Scan_Step_Value",0);
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);
        Logger logger = Logger.getLogger("ScanMotor3Log");  
        FileHandler fh;  

        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/Scan3_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Joint3 Scan Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  

            sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x48, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x42, (byte) ((scanInitValue >>> 8) & 0xFF), (byte) ((scanInitValue) & 0xFF), true); //Ref M1 0

            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");

//            try {
//                Thread.sleep(1500);
//            } catch (InterruptedException ex) {
//                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//            }
                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),0,Read_J1_pos(),0,Read_J2_pos(),scanInitValue,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }


            for (int i = scanInitValue; i <= scanFinalValue; i+=scanStepValue) {
                sendCommand16((byte) 0x42, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),0,Read_J2_pos(),i,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
            for (int i = scanFinalValue; i >= scanInitValue; i-=scanStepValue) {
                sendCommand16((byte) 0x42, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M1 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while ((now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) now=System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),0,Read_J2_pos(),i,Read_J3_pos(),0,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doScanMotor4() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int scanInitValue = getInt("Scan_Init_Value",0);
        final int scanFinalValue = getInt("Scan_Final_Value", 0);
        final int scanStepValue = getInt("Scan_Step_Value",0);
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);
        
        Logger logger = Logger.getLogger("ScanMotor4Log");  
        FileHandler fh;  

        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/Scan4_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Joint4 Scan Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  

            sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
            sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x68, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
            sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
            sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
            sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x62, (byte) ((scanInitValue >>> 8) & 0xFF), (byte) ((scanInitValue) & 0xFF), true); //Ref M4 0
            
            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");
            //try {
                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),0,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),scanInitValue,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }
//                Thread.sleep(1500);
            //} catch  {
            //    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            //}

            for (int i = scanInitValue; i <= scanFinalValue; i+=scanStepValue) {
                sendCommand16((byte) 0x62, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),i,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            for (int i = scanFinalValue; i >= scanInitValue; i-=scanStepValue) {
                sendCommand16((byte) 0x62, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while ((now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) now=System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),0,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),i,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }

//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }
     
    synchronized public void doScanAllMotor() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        // Convert ms time into clock cycles.
        final int scanInitValue = getInt("Scan_Init_Value",0);
        final int scanFinalValue = getInt("Scan_Final_Value", 0);
        final int scanStepValue = getInt("Scan_Step_Value",0);
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);
        
        Logger logger = Logger.getLogger("ScanAllMotor");  
        FileHandler fh;  

        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/ScanAllMotor_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Scan All Motors Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
            int iSIV = scanInitValue, iSFV=scanFinalValue, iSSV=scanStepValue;
            if (scanInitValue > 200) {iSIV = 200;}
            if (scanInitValue < -200) {iSIV = -200;} 
            if (scanFinalValue > 200) {iSFV = 200;}
            if (scanFinalValue < -200) {iSFV = -200;} 
            if (scanStepValue > 200) {iSSV = 200;}
            if (scanStepValue < -200) {iSSV = -200;} 
            sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x02, (byte) ((iSIV >>> 8) & 0xFF), (byte) ((iSIV) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x28, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x22, (byte) ((iSIV >>> 8) & 0xFF), (byte) ((iSIV) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x48, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x42, (byte) ((iSIV >>> 8) & 0xFF), (byte) ((iSIV) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
            sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x68, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
            sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
            sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
            sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x62, (byte) ((iSIV >>> 8) & 0xFF), (byte) ((iSIV) & 0xFF), true); //Ref M4 0
            
            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");
            //try {
                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),0,Read_J1_pos(),0,Read_J2_pos(),0,Read_J3_pos(),scanInitValue,Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }
//                Thread.sleep(1500);
            //} catch  {
            //    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            //}
            for (int j=0; j<10; j++) {
            for (int i = iSIV; i <= iSFV; i+=iSSV) {
                sendCommand16((byte) 0x62, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x42, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x22, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x02, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),i,Read_J1_pos(),i,Read_J2_pos(),i,Read_J3_pos(),i,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            for (int i = iSFV; i >= iSIV; i-=iSSV) {
                sendCommand16((byte) 0x62, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x42, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x22, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x02, (byte) ((i >>> 8) & 0xFF), (byte) ((i) & 0xFF), true); //Ref M4 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while ((now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) now=System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),i,Read_J1_pos(),i,Read_J2_pos(),i,Read_J3_pos(),i,Read_J4_pos()));
                    now = System.currentTimeMillis();
                }

//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doDraw8xy() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        
        final int scanWaitTime = getInt("Scan_Wait_Time", 0);

        Logger logger = Logger.getLogger("Print8xy");  
        FileHandler fh;  

        int [] refsM1 = new int[]  {   0,    0,    0,    0,    0};
        int [] refsM2 = new int[]  {   0, -150, -250, -500,    0};
        int [] refsM3 = new int[]  {-150,    0,  150,  500, -150};
        int [] refsM4 = new int[]  {-100,    0,  150,  300, -100};
        
        if (AERRobot_USBEnable)
        {
            try{
                String timeStamp = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss").format( new Date() );
                fh = new FileHandler("C:/Users/alina/Documents/CITEC_2020_logs/Print8xy_" + timeStamp + ".log");  
                logger.addHandler(fh);
                SimpleFormatter formatter = new SimpleFormatter();  
                fh.setFormatter(formatter);  
                logger.info("CITEC ED-BioRob Print 8 x,y Log file");
                logger.setUseParentHandlers(false);
            } catch (SecurityException e) {  
                e.printStackTrace();  
            } catch (IOException e) {  
                e.printStackTrace();  
            }  
            sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x02, (byte) ((refsM1[0] >>> 8) & 0xFF), (byte) ((refsM1[0]) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x28, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x22, (byte) ((refsM2[0] >>> 8) & 0xFF), (byte) ((refsM2[0]) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x48, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x42, (byte) ((refsM3[0] >>> 8) & 0xFF), (byte) ((refsM3[0]) & 0xFF), true); //Ref M1 0

            sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
            sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x68, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
            sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
            sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
            sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x62, (byte) ((refsM4[0] >>> 8) & 0xFF), (byte) ((refsM4[0]) & 0xFF), true); //Ref M4 0
            
            logger.info("Time\tM1 Ref\tJ1 Pos\tM2 Ref\tJ2 Pos\tM3 Ref\tJ3 Pos\tM4 Ref\tJ4 Pos\t");
            //try {
                long start = System.currentTimeMillis();
                long now = System.currentTimeMillis();
                while (Math.abs(now-start) < 1500) {
                    long lap = System.currentTimeMillis();
                    while (Math.abs(now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(System.currentTimeMillis()-start),refsM1[0],Read_J1_pos(),refsM2[0],Read_J2_pos(),refsM3[0],Read_J3_pos(),refsM4[0],Read_J4_pos()));
                    now = System.currentTimeMillis();
                    
                }
//                Thread.sleep(1500);
            //} catch  {
            //    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            //}
            for (int j=0; j<2; j++) {
            for (int i = 0; i < 5; i+=1) {
                sendCommand16((byte) 0x62, (byte) ((refsM4[i] >>> 8) & 0xFF), (byte) ((refsM4[i]) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x42, (byte) ((refsM3[i] >>> 8) & 0xFF), (byte) ((refsM3[i]) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x22, (byte) ((refsM2[i] >>> 8) & 0xFF), (byte) ((refsM2[i]) & 0xFF), true); //Ref M4 0
                sendCommand16((byte) 0x02, (byte) ((refsM1[i] >>> 8) & 0xFF), (byte) ((refsM1[i]) & 0xFF), true); //Ref M4 0
                
//                System.out.print("Scanning Motor 1 position: ");
//                System.out.println(i);
                long start2 = System.currentTimeMillis();
                now = System.currentTimeMillis();
                while (Math.abs(now-start2) < scanWaitTime) {
                    long lap = System.currentTimeMillis();
                    while ((now-lap) < 100) 
                        now = System.currentTimeMillis();
                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),refsM1[i],Read_J1_pos(),refsM2[i],Read_J2_pos(),refsM3[i],Read_J3_pos(),refsM4[i],Read_J4_pos()));
                    now = System.currentTimeMillis();
                }
//                try {
//                    Thread.sleep(scanWaitTime);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
//            for (int i = 4; i > 0; i-=1) {
//                sendCommand16((byte) 0x62, (byte) ((refsM4[i] >>> 8) & 0xFF), (byte) ((refsM4[i]) & 0xFF), true); //Ref M4 0
//                sendCommand16((byte) 0x42, (byte) ((refsM3[i] >>> 8) & 0xFF), (byte) ((refsM3[i]) & 0xFF), true); //Ref M4 0
//                sendCommand16((byte) 0x22, (byte) ((refsM2[i] >>> 8) & 0xFF), (byte) ((refsM2[i]) & 0xFF), true); //Ref M4 0
//                sendCommand16((byte) 0x02, (byte) ((refsM1[i] >>> 8) & 0xFF), (byte) ((refsM1[i]) & 0xFF), true); //Ref M4 0
//                
////                System.out.print("Scanning Motor 1 position: ");
////                System.out.println(i);
//                long start2 = System.currentTimeMillis();
//                now = System.currentTimeMillis();
//                while ((now-start2) < scanWaitTime) {
//                    long lap = System.currentTimeMillis();
//                    while ((now-lap) < 100) now=System.currentTimeMillis();
//                    logger.info(String.format("%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t,%d\t",(now-start),refsM1[i],Read_J1_pos(),refsM2[i],Read_J2_pos(),refsM3[i],Read_J3_pos(),refsM4[i],Read_J4_pos()));
//                    now = System.currentTimeMillis();
//                }
//
////                try {
////                    Thread.sleep(scanWaitTime);
////                } catch (InterruptedException ex) {
////                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
////                }
//            }
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doExample() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x02, (byte) (0), (byte) (0), true); //Ref M1 0
            sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M2
            sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x28, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M2
            sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M2
            sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M2
            sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x22, (byte) (0), (byte) (0), true); //Ref M2 0
            sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M3
            sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x48, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M3
            sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M3
            sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M3
            sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x42, (byte) (0), (byte) (0), true); //Ref M3 0
            sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
            sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x68, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
            sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
            sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
            sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x62, (byte) (0), (byte) (0), true); //Ref M4 0
            try {
                Thread.sleep(1500);
            } catch (InterruptedException ex) {
                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            }
                //Go to pick up something
                sendCommand16((byte) 0x22, (byte) (( -400 >>> 8) & 0xFF), (byte) ((-400) & 0xFF), true); //Ref M2 0
                sendCommand16((byte) 0x42, (byte) (( -250 >>> 8) & 0xFF), (byte) ((-250) & 0xFF), true); //Ref M3 0
                sendCommand16((byte) 0x62, (byte) (( 400 >>> 8) & 0xFF), (byte) ((400) & 0xFF), true); //Ref M4 0
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Go to home position
                sendCommand16((byte) 0x22, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M2 0
                sendCommand16((byte) 0x42, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M3 0
                sendCommand16((byte) 0x62, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M4 0
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Turn the base 180º
                sendCommand16((byte) 0x2, (byte) (( -600 >>> 8) & 0xFF), (byte) ((-600) & 0xFF), true); //Ref M1 0
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Go to left something same initial position with the base turned (so oposite position for joints
                sendCommand16((byte) 0x22, (byte) (( 400 >>> 8) & 0xFF), (byte) ((400) & 0xFF), true); //Ref M2 0
                sendCommand16((byte) 0x42, (byte) (( 250 >>> 8) & 0xFF), (byte) ((250) & 0xFF), true); //Ref M3 0
                sendCommand16((byte) 0x62, (byte) (( -400 >>> 8) & 0xFF), (byte) ((-400) & 0xFF), true); //Ref M4 0

                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Go to home position
                sendCommand16((byte) 0x22, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M2 0
                sendCommand16((byte) 0x42, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M3 0
                sendCommand16((byte) 0x62, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M4 0

                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Turn the base -180º (home position)
                sendCommand16((byte) 0x2, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M1 0
                
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException ex) {
                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
                }
                //Reset the controller to be silent.
                sendCommand16((byte) 0xff, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
                sendCommand16((byte) 0xfe, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
                sendCommand16((byte) 0xff, (byte) (0x00), (byte) (0x00), true); //FPGA reset
                sendCommand16((byte) 0xfe, (byte) (0x00), (byte) (0x00), true); //FPGA reset
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }
    
    
    synchronized public void doConfigureLEDS() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0, (byte) (0x00),(byte) ((leds_M1) & 0xFF), true); //LEDs M1
            sendCommand16((byte) 0x20, (byte) (0x00),(byte) ((leds_M2) & 0xFF), true); //LEDs M2
            sendCommand16((byte) 0x40, (byte) (0x00),(byte) ((leds_M3) & 0xFF), true); //LEDs M3
            sendCommand16((byte) 0x60, (byte) (0x00),(byte) ((leds_M4) & 0xFF), true); //LEDs M4

        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

        synchronized public void doSwitchOffLEDS() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
                sendCommand16((byte) 0, (byte) 0, (byte) 0, false); //LEDs M1 off
                sendCommand16((byte) 0x20, (byte) 0, (byte) 0, false); //LEDs M2 off
                sendCommand16((byte) 0x40, (byte) 0, (byte) 0, false); //LEDs M3 off
                sendCommand16((byte) 0x60, (byte) 0, (byte) 0, false); //LEDs M4 off
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }
   
    synchronized public void doRead_J1() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            for (int j=0; j<10; j++) {
            int sensor_j1=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sensor_j1 = readSensor((byte)0x01);
                if (sensor_j1 >0) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J1_sensor_value = sensor_j1;
            putInt("J1_sensor_value", sensor_j1);
            System.out.println("Read " + sensor_j1 + " from sensor J1\n");
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }

    }

    synchronized public void doRead_J2() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            for (int j=0; j<10; j++) {
            int sensor_j2=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sensor_j2 = readSensor((byte)0x02);
                if (sensor_j2 >0) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J2_sensor_value = sensor_j2;
            putInt("J2_sensor_value", sensor_j2);
            System.out.println("Read " + sensor_j2 + " from sensor J2\n");
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    synchronized public void doRead_J3() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
       if (AERRobot_USBEnable)
        {
            for (int j=0; j<10; j++) {
            int sensor_j3=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF3, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF3, (byte) (0x00),(byte) (0x00), true); 
                sensor_j3 = readSensor((byte)0x03);
                if ((sensor_j3 & 0x1fff) >0 && (sensor_j3 >> 14) == 3) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J3_sensor_value = sensor_j3 & 0x1fff;
            putInt("J3_sensor_value", sensor_j3 & 0x1fff);
            System.out.println("Read " + String.format("%x",(sensor_j3 & 0x1fff)) + " from sensor J3. Angle (dec) = " + (sensor_j3 & 0x1fff) * 0.02197 + "\n");
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    
    synchronized public void doRead_J4 (){
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
       if (AERRobot_USBEnable)
        {
            for (int j=0; j<10; j++) {
            int sensor_j4=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF4, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF4, (byte) (0x00),(byte) (0x00), true); 
                sensor_j4 = readSensor((byte)0x04);
                //if (sensor_j4 >0) {
                if ((sensor_j4 & 0x1fff) >0 && (sensor_j4 >> 14) == 3) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J4_sensor_value = sensor_j4 & 0x1fff;
            putInt("J4_sensor_value", sensor_j4 & 0x1fff);
            System.out.println("Read " + String.format("%x",(sensor_j4 & 0x1fff)) + " from sensor J4. Angle (dec) = " + (sensor_j4 & 0x1fff) * 0.02197 + "\n");
            }
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }
 
    synchronized public int Read_J1_pos() {
        // Verify that we have a USB device to send to.
        int J1_pos=-1;
        if (AERRobot_USBEnable && devHandle == null) {
            return -1;
        }
        
        if (AERRobot_USBEnable)
        {
            int sensor_j1=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF1, (byte) (0x00),(byte) (0x00), true); 
                sensor_j1 = readSensor((byte)0x01);
                if (sensor_j1 >0) {
                   break;
                }
            }
            J1_pos = sensor_j1;
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
        return J1_pos;
    }
    
    synchronized public int Read_J2_pos() {
        // Verify that we have a USB device to send to.
        int J2_pos=-1;
        if (AERRobot_USBEnable && devHandle == null) {
            return -1;
        }
        
        if (AERRobot_USBEnable)
        {
            //for (int j=0; j<10; j++) {
            int sensor_j2=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF2, (byte) (0x00),(byte) (0x00), true); 
                sensor_j2 = readSensor((byte)0x02);
                if (sensor_j2 >0) {
                   break;
                }
            }
            J2_pos = sensor_j2;
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
        return J2_pos;
    }

    synchronized public int Read_J3_pos (){
        // Verify that we have a USB device to send to.
        int J3_pos=-1;
        if (AERRobot_USBEnable && devHandle == null) {
            return -1;
        }
        
       if (AERRobot_USBEnable)
        {
            //int[] J4_pos = new int[10];
            //for (int j=0; j<10; j++) {
            int sensor_j3=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF3, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF3, (byte) (0x00),(byte) (0x00), true); 
                sensor_j3 = readSensor((byte)0x03);
                //if (sensor_j4 >0) {
                if ((sensor_j3 & 0x1fff) >0 && (sensor_j3 >> 14) == 3) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J3_pos = sensor_j3 & 0x1fff;
            //}
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
       return J3_pos;
    }

    synchronized public int Read_J4_pos (){
        // Verify that we have a USB device to send to.
        int J4_pos=-1;
        if (AERRobot_USBEnable && devHandle == null) {
            return -1;
        }
        
       if (AERRobot_USBEnable)
        {
            //int[] J4_pos = new int[10];
            //for (int j=0; j<10; j++) {
            int sensor_j4=-1;
            for(int i=0 ; i<100; i++)   {
                sendCommand16((byte) 0xF4, (byte) (0x00),(byte) (0x00), true); 
                sendCommand16((byte) 0xF4, (byte) (0x00),(byte) (0x00), true); 
                sensor_j4 = readSensor((byte)0x04);
                //if (sensor_j4 >0) {
                if ((sensor_j4 & 0x1fff) >0 && (sensor_j4 >> 14) == 3) {
                   break;
                }
//                try {
//                    Thread.sleep(10);
//                } catch (InterruptedException ex) {
//                    Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
//                }
            }
            J4_pos = sensor_j4 & 0x1fff;
            //}
        }
        else if (AERNodeOKAERtoolEnable) 
        {
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
       return J4_pos;
    }

synchronized public void doSetAERIN_ref() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0xF0, (byte) (0xFF),(byte) (0xFF), true); 
            sendCommand16((byte) 0xF0, (byte) (0xFF),(byte) (0xFF), true); 
        }
    }
    synchronized public void doSetUSBSPI_ref() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0xF0, (byte) (0x00),(byte) (0x00), true); 
            sendCommand16((byte) 0xF0, (byte) (0x00),(byte) (0x00), true); 
        }
    }

    synchronized public void doSend_Home() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0x03, (byte) (0x00), (byte) ((PI_bank_select_M1)&0xFF), true); //I banks disabled M1
            sendCommand16((byte) 0x07, (byte) ((PI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x08, (byte) (0x00), (byte) ((PD_bank_select_M1)&0xFF), true); //D banks disabled M1
            sendCommand16((byte) 0x0C, (byte) ((PD_FD_bank3_22bits_M1 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x12, (byte) ((SpikeExpansor_M1 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M1) & 0xFF), true); //spike expansor M1
            sendCommand16((byte) 0x13, (byte) (0x00), (byte) ((EI_bank_select_M1)&0xFF), true); //EI bank enabled M1
            sendCommand16((byte) 0x17, (byte) ((EI_FD_bank3_18bits_M1 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M1) & 0xFF), true); //FD I&G bank 3 M1
            sendCommand16((byte) 0x02, (byte) (0), (byte) (0), true); //Ref M1 0
            sendCommand16((byte) 0x23, (byte) (0x00), (byte) ((PI_bank_select_M2)&0xFF), true); //I banks disabled M2
            sendCommand16((byte) 0x27, (byte) ((PI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x28, (byte) (0x00), (byte) ((PD_bank_select_M2)&0xFF), true); //D banks disabled M2
            sendCommand16((byte) 0x2C, (byte) ((PD_FD_bank3_22bits_M2 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x32, (byte) ((SpikeExpansor_M2 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M2) & 0xFF), true); //spike expansor M2
            sendCommand16((byte) 0x33, (byte) (0x00), (byte) ((EI_bank_select_M2)&0xFF), true); //EI bank enabled M2
            sendCommand16((byte) 0x37, (byte) ((EI_FD_bank3_18bits_M2 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M2) & 0xFF), true); //FD I&G bank 3 M2
            sendCommand16((byte) 0x22, (byte) (0), (byte) (0), true); //Ref M2 0
            sendCommand16((byte) 0x43, (byte) (0x00), (byte) ((PI_bank_select_M3)&0xFF), true); //I banks disabled M3
            sendCommand16((byte) 0x47, (byte) ((PI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x48, (byte) (0x00), (byte) ((PD_bank_select_M3)&0xFF), true); //D banks disabled M3
            sendCommand16((byte) 0x4C, (byte) ((PD_FD_bank3_22bits_M3 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x52, (byte) ((SpikeExpansor_M3 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M3) & 0xFF), true); //spike expansor M3
            sendCommand16((byte) 0x53, (byte) (0x00), (byte) ((EI_bank_select_M3)&0xFF), true); //EI bank enabled M3
            sendCommand16((byte) 0x57, (byte) ((EI_FD_bank3_18bits_M3 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M3) & 0xFF), true); //FD I&G bank 3 M3
            sendCommand16((byte) 0x42, (byte) (0), (byte) (0), true); //Ref M3 0
            sendCommand16((byte) 0x63, (byte) (0x00), (byte) ((PI_bank_select_M4)&0xFF), true); //I banks disabled M4
            sendCommand16((byte) 0x67, (byte) ((PI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((PI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x68, (byte) (0x00), (byte) ((PD_bank_select_M4)&0xFF), true); //D banks disabled M4
            sendCommand16((byte) 0x6C, (byte) ((PD_FD_bank3_22bits_M4 >>> 8) & 0xFF), (byte) ((PD_FD_bank3_22bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x72, (byte) ((SpikeExpansor_M4 >>> 8) & 0xFF), (byte) ((SpikeExpansor_M4) & 0xFF), true); //spike expansor M4
            sendCommand16((byte) 0x73, (byte) (0x00), (byte) ((EI_bank_select_M4)&0xFF), true); //EI bank enabled M4
            sendCommand16((byte) 0x77, (byte) ((EI_FD_bank3_18bits_M4 >>> 8) & 0xFF), (byte) ((EI_FD_bank3_18bits_M4) & 0xFF), true); //FD I&G bank 3 M4
            sendCommand16((byte) 0x62, (byte) (0), (byte) (0), true); //Ref M4 0
            try {
                Thread.sleep(2000);
            } catch (InterruptedException ex) {
                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            }
            //Go to home position
            sendCommand16((byte) 0x22, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M2 0
            sendCommand16((byte) 0x42, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M3 0
            sendCommand16((byte) 0x62, (byte) (( 0 >>> 8) & 0xFF), (byte) ((0) & 0xFF), true); //Ref M4 0
            try {
                Thread.sleep(2000);
            } catch (InterruptedException ex) {
                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            }
            //Reset the controller to be silent.
            sendCommand16((byte) 0xff, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
            sendCommand16((byte) 0xfe, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
            sendCommand16((byte) 0xff, (byte) (0x00), (byte) (0x00), true); //FPGA reset
            sendCommand16((byte) 0xfe, (byte) (0x00), (byte) (0x00), true); //FPGA reset

        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }
    
        synchronized public void doSendFPGAReset() {
        // Verify that we have a USB device to send to.
        if (AERRobot_USBEnable && devHandle == null) {
            return;
        }
        
        if (AERRobot_USBEnable)
        {
            sendCommand16((byte) 0, (byte) (0x00),(byte) (0x00), true); //LEDs M1
            sendCommand16((byte) 0x20, (byte) (0x00),(byte) (0x00), true); //LEDs M2
            sendCommand16((byte) 0x40, (byte) (0x00),(byte) (0x00), true); //LEDs M3
            sendCommand16((byte) 0x60, (byte) (0x00),(byte) (0x00), true); //LEDs M4
            try {
                Thread.sleep(100);
            } catch (InterruptedException ex) {
                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            }
            sendCommand16((byte) 0, (byte) (0x00),(byte) (0xFF), true); //LEDs M1
            sendCommand16((byte) 0xff, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
            sendCommand16((byte) 0xfe, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
            sendCommand16((byte) 0xff, (byte) (0x00), (byte) (0x00), true); //FPGA reset
            sendCommand16((byte) 0xfe, (byte) (0x00), (byte) (0x00), true); //FPGA reset
            try {
                Thread.sleep(100);
            } catch (InterruptedException ex) {
                Logger.getLogger(ATCBioRobAERrobotConfig.class.getName()).log(Level.SEVERE, null, ex);
            }
            sendCommand16((byte) 0, (byte) (0x00),(byte) ((leds_M1) & 0xFF), true); //LEDs M1
            sendCommand16((byte) 0x20, (byte) (0x00),(byte) ((leds_M2) & 0xFF), true); //LEDs M2
            sendCommand16((byte) 0x40, (byte) (0x00),(byte) ((leds_M3) & 0xFF), true); //LEDs M3
            sendCommand16((byte) 0x60, (byte) (0x00),(byte) ((leds_M4) & 0xFF), true); //LEDs M4

        }
        else if (AERNodeOKAERtoolEnable) 
        {
            //sendOKAER_nssON();

            // Send all the OMC configuration.
            //sendOKAERSpi((byte) 240, (byte) (IFthreshold & 0xFF)); //F0 240
            //sendOKAER_nssOFF();
            System.out.println("Sending SPI OKAERTool (not implemented)");
       }
    }

    /*public boolean isReset() {
        if (!this.Reset) this.Reset_once = false;
        return Reset;
    }

    public void setReset(final boolean Reset) {
        this.Reset = Reset;
        putBoolean("Reset", Reset);
        if (Reset && !Reset_once) { //sendCommandRST(true); 
            sendCommand16((byte) 0xff, (byte) (0xFF), (byte) (0xFF), true); //FPGA reset
            Reset_once = true;
        }            
        else if (Reset == false) Reset_once = false;
    }*/

    
    public void sendOKAER_nssON()
    {
            OKHardwareInterface.setNSSsignal(false);
    }
    public void sendOKAER_nssOFF()
    {
            OKHardwareInterface.setNSSsignal(true);
    }
    
    public void sendOKAERSpi(byte add, byte dat)  
    {
        //System.out.println(String.format("Sending command - add: %X, dat: %X", add, dat));
        int word_spi = ((add & 0xFF) << 8) + (dat & 0xFF);
        /*int word_spi = add & 0xFF;
        word_spi = word_spi << 8;
        word_spi = word_spi + (dat & 0xFF);
        */
        //if (this.spi) 
        //Send 16bits data word by SPI using a bitmask
        sendOKAER_nssON();
        OKHardwareInterface.sendOKSPIData(word_spi, 0xFFFF);
        /*try {
            Thread.sleep(500);                 //10 milliseconds .
        } catch(InterruptedException ex) {
            Thread.currentThread().interrupt();
        }*/
        sendOKAER_nssOFF();
    }
//    public boolean isDevUSB3Enable() {
//        return DevUSB3Enable;
//    }
//
//    public void setDevUSB3Enable(boolean enable) {
//        putBoolean("DevUSB3Enable", enable);
//        boolean oldValue = this.DevUSB3Enable;
//        this.DevUSB3Enable = enable;
//        support.firePropertyChange("DevUSB3Enable", oldValue, enable);
//        if (enable) {
//            setAERNodeSPIConv64Enable(false);
//            setAERNodeOKAERtoolEnable(false);
//        }
//    }''check
    public boolean isAERRobot_USBEnable() {
        return AERRobot_USBEnable;
    }

    public void setAERRobot_USBEnable(boolean enable) {
        putBoolean("AERRobot_USBEnable", enable);
        boolean oldValue = this.AERRobot_USBEnable;
        this.AERRobot_USBEnable = enable;
        support.firePropertyChange("AERRobot_USBEnable", oldValue, enable);
        //if (enable) {
        //    setAERRobot_USBEnable(false);
            //setDevUSB3Enable(false);
        //}
    }
    
    //public boolean isAERNodeOKAERtoolEnable() {
    //    return AERNodeOKAERtoolEnable;
    //}

    //public void setAERNodeOKAERtoolEnable(boolean enable) {
    //    putBoolean("AERNodeOKAERtoolEnable", enable);
    //    boolean oldValue = this.AERNodeOKAERtoolEnable;
    //    this.AERNodeOKAERtoolEnable = enable;
    //    support.firePropertyChange("AERNodeOKAERtoolEnable", oldValue, enable);
    //    if (enable) {
    //        setAERNodeSPIConv64Enable(false);
    //        //setDevUSB3Enable(false);
    //    }
   // }
    
   

    @Override
    public EventPacket<?> filterPacket(final EventPacket<?> in) {
        // Don't modify events and packets going through.
        return (in);
    }

    // The SiLabs C8051F320 used by ATC has VID=0xC410 and PID=0x0000.
    private final short VID = (short) 0x10C4;
    private final short PID = 0x0000;

    private final byte ENDPOINT = 0x02;
    private final byte IN_ENDPOINT = (byte)0x81;
    private final int PACKET_LENGTH = 64;

    private DeviceHandle devHandle = null;

    private void openDevice() {
        System.out.println("Searching for device.");

        // Already opened.
        if (devHandle != null) {
            return;
        }

        // Search for a suitable device and connect to it.
        LibUsb.init(null);

        final DeviceList list = new DeviceList();
        if (LibUsb.getDeviceList(null, list) > 0) {
            final Iterator<Device> devices = list.iterator();
            while (devices.hasNext()) {
                final Device dev = devices.next();

                final DeviceDescriptor devDesc = new DeviceDescriptor();
                LibUsb.getDeviceDescriptor(dev, devDesc);

                if ((devDesc.idVendor() == VID) && (devDesc.idProduct() == PID)) {
                    // Found matching device, open it.
                    devHandle = new DeviceHandle();
                    if (LibUsb.open(dev, devHandle) != LibUsb.SUCCESS) {
                        devHandle = null;
                        continue;
                    }

                    final IntBuffer activeConfig = BufferUtils.allocateIntBuffer();
                    LibUsb.getConfiguration(devHandle, activeConfig);

                    if (activeConfig.get() != 1) {
                        LibUsb.setConfiguration(devHandle, 1);
                    }

                    LibUsb.claimInterface(devHandle, 0);

                    System.out.println("Successfully found device.");
                }
            }

            LibUsb.freeDeviceList(list, true);
        }
    }

    private void closeDevice() {
        System.out.println("Shutting down device.");

        // Use reset to close connection.
        if (devHandle != null) {
            LibUsb.releaseInterface(devHandle, 0);
            LibUsb.close(devHandle);
            devHandle = null;

            LibUsb.exit(null);
        }
    }

    
    /**
 * Reads some data from the device.
 * 
 * @param handle
 *            The device handle.
 * @param size
 *            The number of bytes to read from the device.
 * @return The read data.
 */
    private int readSensor(byte sensor)
    {
        //System.out.println(String.format("Sending request for reading usb packet"));

        // Check for presence of ready device.
        if (devHandle == null) {
            return -1;
        }

        // Prepare message.
        final ByteBuffer dataBuffer = BufferUtils.allocateByteBuffer(PACKET_LENGTH);

        dataBuffer.put(0, (byte) 'A');
        dataBuffer.put(1, (byte) 'T');
        dataBuffer.put(2, (byte) 'C');
        dataBuffer.put(3, (byte) 0x02); // Command always 2 for reading operation.
        dataBuffer.put(4, (byte) 64); // Data length always 3 for 3 bytes.

        // Send bulk transfer request on given endpoint.
        final IntBuffer transferred = BufferUtils.allocateIntBuffer();
        LibUsb.bulkTransfer(devHandle, ENDPOINT, dataBuffer, transferred, 0);
        if (transferred.get(0) != PACKET_LENGTH) {
            System.out.println("Failed to transfer whole packet.");
        }
        
        
        ByteBuffer buffer = BufferUtils.allocateByteBuffer(PACKET_LENGTH);
        int result = 0;
        LibUsb.bulkTransfer(devHandle, IN_ENDPOINT, buffer, transferred, 0);
        if (result != LibUsb.SUCCESS)
        {
            System.out.println("Failed to read-transfer data from LibUSB device.");
        }
        //System.out.println(transferred.get() + " bytes read from device");
        int sensor_data=0;
        if (buffer.get(34)==sensor)
            sensor_data = (0x0ff & buffer.get(35))*256 + buffer.get(36);
        else sensor_data = -1;

        return sensor_data;
    }
    private void sendCommand16(final byte cmd, final byte data1,final byte data2, final boolean spiEnable) {
        //System.out.println(String.format("Sending command - cmd: %X, data1: %X, data2: %X", cmd, data1, data2));

        // Check for presence of ready device.
        if (devHandle == null) {
            return;
        }

        // Prepare message.
        final ByteBuffer dataBuffer = BufferUtils.allocateByteBuffer(PACKET_LENGTH);

        dataBuffer.put(0, (byte) 'A');
        dataBuffer.put(1, (byte) 'T');
        dataBuffer.put(2, (byte) 'C');
        dataBuffer.put(3, (byte) 0x01); // Command always 1 for SPI upload.
        dataBuffer.put(4, (byte) 0x02); // Data length always 2 for 2 bytes.
        dataBuffer.put(5, (byte) 0x00);
        dataBuffer.put(6, (byte) 0x00);
        dataBuffer.put(7, (byte) 0x00);
        dataBuffer.put(8, cmd); // Send actual SPI command (address usually).
        dataBuffer.put(9, (byte) ((spiEnable) ? (0x00) : (0x01)));
		// Enable or disable SPI communication.

        // Send bulk transfer request on given endpoint.
        final IntBuffer transferred = BufferUtils.allocateIntBuffer();
        LibUsb.bulkTransfer(devHandle, ENDPOINT, dataBuffer, transferred, 0);
        if (transferred.get(0) != PACKET_LENGTH) {
            System.out.println("Failed to transfer whole packet.");
        }

        // Put content in a second packet.
        dataBuffer.put(0, cmd);
        dataBuffer.put(1, data1);
        dataBuffer.put(2, data2);

        // Send second bulk transfer request on given endpoint.
        LibUsb.bulkTransfer(devHandle, ENDPOINT, dataBuffer, transferred, 0);
        if (transferred.get(0) != PACKET_LENGTH) {
            System.out.println("Failed to transfer whole packet.");
        }
    }
    private void sendCommandRST(final boolean spiEnable) {
        System.out.println(String.format("Sending RESET to FPGA"));

        // Check for presence of ready device.
        if (devHandle == null) {
            return;
        }

        // Prepare message.
        final ByteBuffer dataBuffer = BufferUtils.allocateByteBuffer(PACKET_LENGTH);

        dataBuffer.put(0, (byte) 'A');
        dataBuffer.put(1, (byte) 'T');
        dataBuffer.put(2, (byte) 'C');
        dataBuffer.put(3, (byte) 0x04); // Command always 4 for FPGA reset.
        dataBuffer.put(4, (byte) 0x00); // Data length 0.
        dataBuffer.put(5, (byte) 0x00);
        dataBuffer.put(6, (byte) 0x00);
        dataBuffer.put(7, (byte) 0x00);
        dataBuffer.put(8, (byte) 0x00); // Send actual SPI command (address usually).
        dataBuffer.put(9, (byte) ((spiEnable) ? (0x00) : (0x01)));
		// Enable or disable SPI communication.

        // Send bulk transfer request on given endpoint.
        final IntBuffer transferred = BufferUtils.allocateIntBuffer();
        LibUsb.bulkTransfer(devHandle, ENDPOINT, dataBuffer, transferred, 0);
        if (transferred.get(0) != PACKET_LENGTH) {
            System.out.println("Failed to transfer whole packet.");
        }
    }

    @Override
    public void resetFilter() {
        // Close any open device, and then open a new one.
        closeDevice();
        openDevice();
//        if(this.AERNodeOKAERtoolEnable)
//        {
//            this.sendOKAER_nssOFF();
//        }
    }

    @Override
    public void initFilter() {
        // Open the device for the first time.
        openDevice();
    }
}
