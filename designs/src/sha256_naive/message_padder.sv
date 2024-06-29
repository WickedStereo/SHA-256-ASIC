`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2024 19:39:39
// Design Name: 
// Module Name: message_padder
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

module message_padder #(
  parameter MSG_BITS = 96,
  parameter PADDED_BITS = 512
) 
(
  input logic [MSG_BITS-1:0] message,
  output logic block_count,
  output logic [PADDED_BITS-1:0] padded_message
);
  
  localparam ZERO_BITS = PADDED_BITS - MSG_BITS - 1 - 64;

  logic [PADDED_BITS-1:0] padded_message_reg;

  assign padded_message_reg[PADDED_BITS-1:PADDED_BITS-MSG_BITS] = message;
  assign padded_message_reg[PADDED_BITS-MSG_BITS-1] = 1'b1;
  assign padded_message_reg[PADDED_BITS-MSG_BITS-2-:ZERO_BITS] = '0;
  assign padded_message_reg[63:0] = MSG_BITS;

  assign padded_message = padded_message_reg;
  assign block_count = 1;
  
endmodule