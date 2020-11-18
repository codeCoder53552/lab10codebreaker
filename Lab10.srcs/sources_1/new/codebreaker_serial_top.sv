`default_nettype none
module codebreaker_serial_top(
    input wire logic            clk,
    input wire logic            btnu, // reset

    input wire logic            btnc,
    output logic        [15:0]  led,

    output logic        [3:0]   anode,
    output logic        [7:0]   segment,

    output logic tx_out
);

logic           clk_100;                //  System Clock
//logic           clk_25;                 //  VGA Monitor clock
logic           reset;                  //  Active-high reset

logic   [15:0]  seven_seg_data;         //  Value to display on the 4 seven-seg displays

logic           stopwatch_run;          //  Active-high enable for stopwatch

logic           enable_drawing_plaintext;
logic           done_drawing_plaintext;
logic   [127:0] plaintext;

assign reset = btnu;

// VGA module needs 25MHz clock, so use this module to generate 
// a 25MHz clock, based on the 100MHz input clock.
//clk_generator clk_generator_inst
// (
//    .clk_100(clk_100),
//    .clk_25(clk_25),
//    .clk_in_100(clk)
// );
assign clk_100 = clk;
 
CharDrawer_serial CharDrawer_inst(
    .clk(clk_100),
    .reset(reset),
    .enable(enable_drawing_plaintext),
    .done(done_drawing_plaintext),
    .tx(tx_out),
    .string_in(plaintext)
);

// Seven-Segment Controller used for the stopwatch
SevenSegmentControl SSC (
    .clk(clk_100),
    .reset(reset),		
    .dataIn(seven_seg_data), 
    .digitDisplay(4'hF),
    .digitPoint(4'b0100),
    .anode(anode),
    .segment(segment)
);

// Stopwatch module from previous lab, used to track how 
// long it takes to find the correct key.
stopwatch stopwatch_inst (
    .clk(clk_100),
    .reset(reset),
    .run(stopwatch_run),
	.digit3(seven_seg_data[15:12]),
	.digit2(seven_seg_data[11:8]),
	.digit1(seven_seg_data[7:4]),
	.digit0(seven_seg_data[3:0])
    );

// Module for this lab, responsible for cracking the key, and 
// displaying the decoded message.
Codebreaker Codebreaker_inst(
    .clk(clk_100),
    .reset(reset),
    .start(btnc),    
    .key_display(led),
    .stopwatch_run(stopwatch_run),
    .draw_plaintext(enable_drawing_plaintext),
    .done_drawing_plaintext(done_drawing_plaintext),
    .plaintext_to_draw(plaintext)
);


endmodule