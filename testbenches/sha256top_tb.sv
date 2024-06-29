`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2024 00:05:45
// Design Name: 
// Module Name: sha256top_tb
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


module sha256top_tb();
    logic clk, reset;
    logic [95:0] message;
    logic trigger;
    logic [255:0] H_out;
    
    
    sha256top mytop
    (
        .clk(clk),
        .reset(reset),
        .message(message),
        .trigger(trigger),
        .H_out(H_out)
    );
    
    always
    begin
        clk = ~clk;
        #10;
    end
    
    initial begin
        trigger = 0;
        clk = 0;
        reset = 1;        
        message = "weloveaustin";
        @(posedge trigger);
        @(posedge clk);
        @(posedge clk);
        reset = 0;
        #1500;
        $finish;
    end
    
endmodule
