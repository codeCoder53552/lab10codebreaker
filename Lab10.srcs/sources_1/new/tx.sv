`timescale 1ns / 1ps

/***************************************************************************
* 
* Module: tx
*
* Author: Colby Weber
* Class: - ECEN 220, Section 1, Winter 2020
* Date: 11/17/20
*
* Description: Outputs a uart tx signal depending on the input recieved
* from top module
*
****************************************************************************/

`default_nettype none
module tx(
    input wire logic clk, Reset, Send,
    input wire logic [7:0] Din,
    output logic Sent, Sout
    );
    
    typedef enum logic [2:0] {Idle, Start, Bits, Par, Stop, Ack, ERR = 'X} StateType;
    StateType cs, ns;
    
    logic clrTimer, timerDone;
    BaudRateTimer baudTimer(.clk(clk), .run(1), .reset(clrTimer), .pulse(timerDone));
    
    logic incBit, clrBit, bitDone;
    logic [3:0] bitNum;
    BitCounter #(8) bitCounter(.clk(clk), .inc(incBit), .reset(clrBit), .count(bitNum), .rolling_over(bitDone));
    
    logic startBit, dataBit, parityBit;
    
    always_comb begin
        clrTimer = 0;
        startBit = 0;
        dataBit = 0;
        parityBit = 0;
        clrBit = 0;
        incBit = 0;
        Sent = 0;
        if (Reset)
            ns = Idle;
        else
            case(cs)
                Idle: begin
                    clrTimer = 1;
                    if (Send)
                        ns = Start;
                    else
                        ns = Idle;
                end
                Start: begin
                    startBit = 1;
                    if (timerDone) begin
                        clrBit = 1;
                        ns = Bits;
                    end else
                        ns = Start;
                end
                Bits: begin
                    dataBit = 1;
                    if (timerDone & bitDone)
                        ns = Par;
                    else if (timerDone & !bitDone) begin
                        ns = Bits;
                        incBit = 1;
                    end else
                        ns = Bits;
                end
                Par: begin
                    parityBit = 1;
                    if (timerDone)
                        ns = Stop;
                    else
                        ns = Par;
                end
                Stop:
                    if (timerDone)
                        ns = Ack;
                    else
                        ns = Stop;
                Ack: begin
                    Sent = 1;
                    if (!Send)
                        ns = Idle;
                    else
                        ns = Ack;
                end
                default:
                    ns = ERR;
            endcase
    end
    
    always_ff @(posedge clk) begin
        cs <= ns;
        if (startBit)
            Sout <= 0;
        else if (dataBit)
            Sout <= Din[bitNum];
        else if (parityBit)
            Sout <= ~^Din;
        else
            Sout <= 1;
    end
    
endmodule