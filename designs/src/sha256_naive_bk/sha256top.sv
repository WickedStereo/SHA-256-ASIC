`timescale 1ns / 1ps

module sha256top #(parameter MSG_BITS = 96, parameter PADDED_BITS = 512) 
(
    input clk,
    input reset,
    input [MSG_BITS-1:0] message,
    output trigger,
    output [255:0] H_out
    );
    
    // Wires
    logic [PADDED_BITS-1:0] padded_message; 
    logic block_count;
    logic done;
    logic [31:0] W_in;
    logic [255:0] H;
    //logic done_sch = 1;
    
    // Constants
    logic [255:0] H0 = 256'b0110101000001001111001100110011110111011011001111010111010000101001111000110111011110011011100101010010101001111111101010011101001010001000011100101001001111111100110110000010101101000100011000001111110000011110110011010101101011011111000001100110100011001;
    
    
    message_padder mypadder(
    .message(message),
    .block_count(block_count),
    .padded_message(padded_message)
    );
    
    message_scheduler myscheduler(
    .clk(clk),
    .block_count(block_count),
    .block_in(padded_message),
    .trigger(trigger),
    .W(W_in)
    );
    
    naive_bk mynaive(
    .clk(clk),
    .reset(reset),
    .block_count(block_count),
    .W(W_in),
    .H_in(H0),
    .H_out(H),
    .done(done)    
    );
    
    //assign H_in = done_hash ? H : H0;
    assign H_out = H;
    
endmodule
 
