`timescale 1ns / 1ps
/***************************************************************************
* 
* Module: FiveMSCounter
*
* Author: Colby Weber
* Class: - ECEN 220, Section 1, Winter 2020
* Date: 10/28/20
*
* Description: outputs a 1 clock pulse every 5ms given a 100mHz clock
*
****************************************************************************/

`default_nettype none
module BaudRateTimer(
    input wire logic clk, run, reset,
    output logic pulse
    );
    logic [12:0] count = '0;
    always_ff @(posedge clk) begin
        if (reset)
            count <= '0;
        else if (count >= 20'd5208 && run)
            count <= '0;
        else if (run)
            count <= count + 1;
        else 
            count <= count;
    end
    always_comb begin
        if (count == 20'd5208)
            pulse = 1;
        else
            pulse = 0;
    end
endmodule