`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2024 14:50:28
// Design Name: 
// Module Name: topmodule
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

// Constraints
// Message Scheduler is designed for maximum 2 blocks. 
// Message scheduler can create maximum of 2 set of 64 words.


module message_scheduler(
    input clk,
    input [1:0] block_count,
    input [511:0] block_in,
    output logic trigger,
    output logic [31:0] W
    );
    
    logic [0:63][31:0] Word;
    logic [0:511] in;
    
    assign in = block_in;
    
// Functions
    function automatic [31:0] rightshift;
        input [31:0] w;
        input [3:0] length;
        rightshift = w >> length;
    endfunction
    
    function automatic [31:0] rightrotate;
            input [31:0] w;
            input [4:0] length;
            rightrotate = (w >> length) | (w << (32 - length));
    endfunction
    
    function automatic [31:0] sigma1;
        input [31:0] w;
        logic [31:0] res1,res2,res3;
        res1 = rightrotate(w, 17);
        res2 = rightrotate(w,19);
        res3 = rightshift(w,10);
        sigma1 = res1 ^ res2 ^ res3;
    endfunction

    function automatic [31:0] sigma0;
        input [31:0] w;
        logic [31:0] res1,res2,res3;
        res1 = rightrotate(w, 7);
        res2 = rightrotate(w,18);
        res3 = rightshift(w,3);
        sigma0 = res1 ^ res2 ^ res3;
    endfunction
     

    integer j = 0;
    integer l; 
    integer k = 0;
    int unsigned i;
    //reg trigger;
    

    always@ (posedge clk)
    begin
        if (j < 'd16) begin
            Word[j] <= in[32*j +: 32];
            j <= j + 1;
            trigger <= 1;
        end
        else if ('d15 < j < 'd64) begin
            Word[j] <= (sigma1(Word[j-2]) + Word[j-7] + sigma0(Word[j-15]) + Word[j-16]);
            j <= j + 1;
        end
        else begin
            j <= 0; 
            trigger <= 0;
        end            
    end
       
    // Output logic
    always@ (posedge clk)
    begin
        if(k < 64 && trigger) begin
            W <= Word[k];
            k <= k + 1;
        end
    end
    
endmodule
