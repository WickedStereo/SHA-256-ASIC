`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.04.2024 11:19:26
// Design Name: 
// Module Name: message_scheduler_tb
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


module message_scheduler_tb();
    logic clk,reset,done;
    logic [1:0] block_count;
    logic [511:0] block_in;
    logic [0:63][31:0] W;
    
    always begin
    #10;
        clk = ~clk;
    end
    
    task initialize;
        begin
            block_count = 2;
            block_in = 512'd3;
            done = 0;
        end
    endtask
    
    message_scheduler mymessagescheduler(clk,reset,done,block_count,block_in,W);
    
    initial
        begin
            clk = 1;
            initialize;
            reset = 1;
            #10;
            reset = 0;
            #10;
            done = 1;
            #10;
            done = 0;
            #10;
            block_in = 512'd4;
            done = 1;
            #10;
            done = 0;
            $finish;  
        end
        
     initial 
        begin
            $monitor("Word -> %b,  time -> %t",W,$time);
        end
    
endmodule
