//% @file MiniProject_DE270_tb.sv
//% @author Petros Fountas
//% @brief Single Channel Data Acquisition system testbench.
`timescale 1ns/1ps

module MiniProject_DE270_tb;

  //% 25 MHz
  parameter CLOCK_25_T = 40; //ns, F_sys = 25 MHz
  reg CLOCK_25 = 1'b0; 
  always begin
    #(CLOCK_25_T/2) CLOCK_25 = 1'b1;
    #(CLOCK_25_T/2) CLOCK_25 = 1'b0;
  end
  
  //% 50 MHz
  parameter CLOCK_50_T = 20; //ns, F_s = 50 MHz
  reg CLOCK_50 = 1'b0; 
  always begin
    #(CLOCK_50_T/2) CLOCK_50 = 1'b1;
    #(CLOCK_50_T/2) CLOCK_50 = 1'b0;
  end
  
  // ************************
  // Device-Under-Test
  // ************************
  
  reg         Reset_n;
  
  reg         Configure;
  reg  [9:0]  Pattern;
  reg  [9:0]  PeriodDelay;
  wire [0:0]  Signal;
  
  reg  [2:0]  TRG_MODE;
  
  reg  [1:0]  INPUT_SELECT;
  
  wire [8:0]  DIG1_RDO_Add;
  wire        DIG1_RDO_Req,
              DIG1_RDO_Done;
  wire        DIG1_RDO_Ack;
  wire [0:0]  DIG1_RDO_Q;
  
  wire [7:0]  VGADRV_X,
              VGADRV_Y;
  wire        VGADRV_WR;
  wire [11:0] VGADRV_RGB;
  
  reg  [0:0]  DIG1_TDiv;
  reg  [7:0]  DIG1_VShift;
  
  // Signal Generator
  DSGEN DSGEN_inst (
    .Clock       ( CLOCK_50    ),
    .Reset_n     ( Reset_n     ),
    .Configure   ( Configure   ),
    .Pattern     ( Pattern     ),
    .PeriodDelay ( PeriodDelay ),
    .SignalOut   ( Signal      )); 
  
  // SCDAQ
  defparam SCDAQ_inst.NSAMPLES     = 512;
  defparam SCDAQ_inst.PRECISION    = 1;
  defparam SCDAQ_inst.RDO_ADD_BLEN = 9;
  SCDAQ SCDAQ_inst (
    .Reset_n    ( Reset_n       ),
    .DAQ_Clock  ( CLOCK_50      ),
    .DAQ_D      ( Signal        ),
    .TRG_MODE   ( TRG_MODE      ),
    .TRG_LVL    ( { 1'b0 }      ),
    .RDO_Clock  ( CLOCK_25      ),
    .RDO_Add    ( DIG1_RDO_Add  ),
    .RDO_Req    ( DIG1_RDO_Req  ),
    .RDO_Ack    ( DIG1_RDO_Ack  ),
    .RDO_Q      ( DIG1_RDO_Q    ),
    .RDO_Done   ( DIG1_RDO_Done ));
    
  // Plot Signal
  PlotSignal PlotSignal_inst (
    .Clock         ( CLOCK_25      ),
    .Reset_n       ( Reset_n       ),
    .X             ( VGADRV_X      ), 
    .Y             ( VGADRV_Y      ),
    .WR            ( VGADRV_WR     ),
    .RGB           ( VGADRV_RGB    ),
    .INPUT_SELECT  ( INPUT_SELECT  ),
    .DIG1_RDO_Add  ( DIG1_RDO_Add  ),
    .DIG1_RDO_Req  ( DIG1_RDO_Req  ),
    .DIG1_RDO_Ack  ( DIG1_RDO_Ack  ),
    .DIG1_RDO_Q    ( DIG1_RDO_Q    ),
    .DIG1_RDO_Done ( DIG1_RDO_Done ),
    .DIG1_TDiv     ( DIG1_TDiv     ),
    .DIG1_VShift   ( DIG1_VShift   ));
  
  // ************************
  // Test 
  // ************************
  
  initial begin
    
    #100  // wait for chip to initialise
    
    $display("Test initiated");
    Reset_n  = 1'b0;
    Pattern     = 10'b1110000000;
    DIG1_TDiv   = 1'b0;
    DIG1_VShift = 8'b00000000;
    
    // Reset_n [Pulse]
    Reset_n = 1'b0;
    #(3*CLOCK_25_T) // 75 ns
    Reset_n = 1'b1;
    INPUT_SELECT = 0;
    
    #(3*CLOCK_25_T) // 75 ns
    INPUT_SELECT = 1;
    
    // Digital Signal
    Pattern  = 10'b1110000000;
    PeriodDelay = 4; //cycles
    Configure   = 1'b1;
    #(1*CLOCK_25_T) Configure   = 1'b1;
     
    // Nedgedge trigger
    TRG_MODE = 3;
    
    #(500*CLOCK_25_T) // 20 us
    
    #10 $display("Test completed");
    $finish;
  end

endmodule
