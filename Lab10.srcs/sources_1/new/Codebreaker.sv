`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2020 06:12:07 PM
// Design Name: 
// Module Name: Codebreaker
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`default_nettype none
module Codebreaker(
    input wire logic clk, reset, start,
    output logic [15:0] key_display,
    output logic stopwatch_run, draw_plaintext,
    input wire logic done_drawing_plaintext,
    output logic [127:0] plaintext_to_draw
    );
    assign key_display = key;
    assign plaintext_to_draw = {"Hello World!"};
//    assign draw_plaintext = start;
    typedef enum logic [2:0] {s0, s1, s2, s3, s4, ERR='X} StateType;
    StateType ns, cs;
    
    logic [23:0] key;
    logic [127:0] cyphertext;
    assign key = 24'h79726a;
    assign cyphertext = 128'h93a931affae622e10a029bd3d4bd6ced;
    logic dce, dcd;
    decrypt_rc4 decript0(.clk(clk), .reset(reset), .enable(dce), .key(key),
        .bytes_in(cyphertext), .bytes_out(/*plaintext_to_draw*/), .done(dcd));
    
    always_comb begin
        dce = 0;
        draw_plaintext = 0;
        stopwatch_run = 0;
        if (reset)
            ns = s0;
        else begin
            case(cs)
                s0:
                    if(start)
                        ns = s1;
                    else
                        ns = s0;
                s1: begin
                    dce = 1;
                    stopwatch_run = 1;
                    if (dcd)
                        ns = s4;
                    else
                        ns = s1;
                end
                s2: begin
                    draw_plaintext = 1;
                    if (done_drawing_plaintext)
                        ns = s3;
                    else
                        ns = s2;
                end
                s3:
                    ns = s3;
                s4:
                    ns = s2;
                default:
                    ns = ERR;
            endcase
        end
    end
    always_ff @(posedge clk) begin
        cs <= ns;
    end
    
endmodule
