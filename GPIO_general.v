
// This is a modified version of:
// file: full_v1_selectio_wiz_0_1_selectio_wiz.v
// To include pin masking
//----------------------------------------------------------------------------

`timescale 1ps/1ps

module GPIO_Red_Pitaya_General
   // width of the data for the system
 #(
   // width of the data for the device
   parameter BUS_WIDTH = 8)
 (
  inout  [BUS_WIDTH-1:0] GPIO_Pin,
  output [BUS_WIDTH-1:0] read_from_pin,
  // From the device out to the system
  input  [BUS_WIDTH-1:0] write_to_pin,
  input  [BUS_WIDTH-1:0] tristate_bitmask,		//this selects the io state, 1 is input, 0 is output
  input              clk_in,       		 	// Single ended clock from IOB
  //output             clk_out,				//uncomment line 55 to enable clk_out
  input              io_reset);
  wire clock_enable = 1'b1;
  // Signal declarations
  ////------------------------------
  // After the buffer
  wire   [BUS_WIDTH-1:0] data_in_from_pins_int;
  // Between the delay and serdes
  wire [BUS_WIDTH-1:0]  data_in_from_pins_delay;
  // Before the buffer
  wire   [BUS_WIDTH-1:0] data_out_to_pins_int;
  // Between the delay and serdes
  wire   [BUS_WIDTH-1:0] data_out_to_pins_predelay;
  // Before the buffer
  wire   [BUS_WIDTH-1:0] tristate_int;
  // Between the delay and serdes
  wire   [BUS_WIDTH-1:0] tristate_predelay;
  // Create the clock logic

wire   [BUS_WIDTH-1:0] tristate_output;
assign tristate_output = tristate_bitmask;

  IBUF
    #(.IOSTANDARD ("LVCMOS33"))
   ibuf_clk_inst
     (.I          (clk_in),
      .O          (clk_in_int));
  
   // BUFR generates the slow clock
   BUFR
    #(.SIM_DEVICE("7SERIES"),
    .BUFR_DIVIDE("BYPASS"))
    clkout_buf_inst
    (.O (clk_div),
     .CE(),
     .CLR(),
     .I (clk_in_int));

   //assign clk_out = clk_div; // This is regional clock;
   
  // We have multiple bits- step over every bit, instantiating the required elements
  genvar pin_count;
  generate for (pin_count = 0; pin_count < BUS_WIDTH; pin_count = pin_count + 1) begin: pins
    // Instantiate the buffers
    ////------------------------------
    // Instantiate a buffer for every bit of the data bus
    IOBUF
      #(.IOSTANDARD ("LVCMOS33"))
     iobuf_inst
       (.IO         (GPIO_Pin[pin_count]),
        .I          (data_out_to_pins_int [pin_count]),
        .O          (data_in_from_pins_int[pin_count]),
        .T          (tristate_int         [pin_count]));

    // Pass through the delay
    ////-------------------------------
 
   assign data_in_from_pins_delay[pin_count] = data_in_from_pins_int[pin_count];
   assign data_out_to_pins_int[pin_count]    = data_out_to_pins_predelay[pin_count];
   assign tristate_int[pin_count]            = tristate_predelay[pin_count];
    // Connect the delayed data to the fabric
    ////--------------------------------------

    // Pack the registers into the IOB
    assign tristate_predelay[pin_count] = tristate_output[pin_count];

    wire data_in_to_device_int;
    (* IOB = "true" *)
    FDRE fdre_in_inst
      (.D              (data_in_from_pins_delay[pin_count]),
       .C              (clk_div),
       .CE             (clock_enable),
       .R              (io_reset),
       .Q              (data_in_to_device_int)
      );
    assign read_from_pin[pin_count] = data_in_to_device_int;
    wire data_out_from_device_q;
    (* IOB = "true" *)
    FDRE fdre_out_inst
      (.D              (write_to_pin[pin_count]),
       .C              (clk_div),
       .CE             (clock_enable),
       .R              (io_reset),
       .Q              (data_out_from_device_q)
      );
    assign data_out_to_pins_predelay[pin_count] = data_out_from_device_q;
  end
  endgenerate

endmodule
