`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.04.2024 17:53:02
// Design Name: 
// Module Name: common_test
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
module common_test (
);

    logic clk, reset;
    logic [255:0] H_out;
    logic [31:0] W;
    logic block_count = 1;
    logic done;
     // Constants
    logic [255:0] H_in = 256'b0110101000001001111001100110011110111011011001111010111010000101001111000110111011110011011100101010010101001111111101010011101001010001000011100101001001111111100110110000010101101000100011000001111110000011110110011010101101011011111000001100110100011001;
    
    always begin
	#10;
        clk = ~clk;
    end

    naive mynaive(clk,reset,block_count,W,H_in,H_out, done);
   
               
    initial begin
        clk = 1;
        reset = 1;
        @(posedge clk);
        reset = 0;
        #100;
        wait (done);
        $finish;
    end
    
     
    
     
endmodule







