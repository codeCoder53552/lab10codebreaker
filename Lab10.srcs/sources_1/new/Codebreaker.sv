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
    assign key_display = key[23:8];
//    assign plaintext_to_draw = {"Hello World!"};
    logic [127:0] correct;
    assign correct = 128'h204543454e203232302049532046554e;
    //assign plaintext_to_draw = correct;
    typedef enum logic [2:0] {Idle, Decode, Transmit, Done, ERR='X} StateType;
    StateType ns, cs;
    
    logic [23:0] key;
    logic [127:0] cyphertext;
    assign key = 24'h79726a;
    assign cyphertext = 128'h93a931affae622e10a029bd3d4bd6ced;
    logic dce, dcd; // decript enable, decript done
    decrypt_rc4 decript0(.clk(clk), .reset(reset), .enable(dce), .key(key),
        .bytes_in(cyphertext), .bytes_out(plaintext_to_draw), .done(dcd));
    
    always_comb begin
        dce = 0; // decript enable
        draw_plaintext = 0;
        stopwatch_run = 0;
        ns = ERR;
        if (reset)
            ns = Idle;
        else begin
            case(cs)
                Idle: // wait for signal
                    if(start)
                        ns = Decode;
                    else
                        ns = Idle;
                Decode: begin // wait for decode to be done
                    dce = 1; // decode enable
                    stopwatch_run = 1;
                    if (dcd) // decode done
                        ns = Transmit;
                    else
                        ns = Decode;
                end
                Transmit: begin // wait for transmit
//                    dce = 1;
//                    plaintext_to_draw = bitOut;
                    draw_plaintext = 1;
                    if (done_drawing_plaintext)
                        ns = Done;
                    else
                        ns = Transmit;
                end
                Done:
                    ns = Done;
//                s3:
//                    if(start)
//                        ns = s4;
//                    else
//                        ns = s3;
//                s4: begin
//                    plaintext_to_draw = 128'h204543454e203232302049532046554e;
//                    draw_plaintext = 1;
//                    if(done_drawing_plaintext)
//                        ns = s0;
//                    else
//                        ns = s4;
//                end
//                default:
///                    ns = ERR;
            endcase
        end
    end
    always_ff @(posedge clk) begin
        cs <= ns;
    end
    
endmodule
