`timescale 1ns / 1ps
/***************************************************************************
*
* Module: BitCounter
*
* Author: Colby Weber
* Class: - ECEN 220, Section 1, Winter 2020
* Date: 10/28/20
*
* Description: Counter that counts until MOD_VALUE - 1 and then sets carry bit
* to high
*
****************************************************************************/

`default_nettype none
module BitCounter #(parameter MOD_VALUE = 10)(
    input wire logic clk, inc, reset,
    output logic rolling_over,
    output logic [3:0] count
    );
    logic [3:0] cnt = '0;
    assign count = cnt;
    //reg[3:0] count;
    always_ff @(posedge clk) begin
        if (reset)
            cnt <= '0;
        else if (cnt >= MOD_VALUE - 1 && inc)
            cnt <= '0;
        else if (inc)
            cnt <= cnt + 1;
        else
            cnt <= cnt;
    end
    always_comb begin
        if (cnt == MOD_VALUE - 1)// && !inc)
            rolling_over = 1;
        else
            rolling_over = 0;
    end
endmodule
