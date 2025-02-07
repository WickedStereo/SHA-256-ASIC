//////////////////////////////////////////////////////////////////////////////////
// Module: message_scheduler
// Function: Message Schedule Generator
// Standard: NIST FIPS 180-4 §6.2.2
// Parameters:
//   BLOCK_SIZE = 512 - Input block size (bits)
// Ports:  
//   clk        - System clock
//   block_in	- Input block [BLOCK_SIZE-1:0]
//   W          - Scheduled word [31:0]
// Features:
//   - 64-stage word generator
//   - Implements σ0/σ1 mixing functions
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
    
    logic [0:2047] Word;
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

	// σ0 mixing function defined in FIPS 180-4
    function automatic [31:0] sigma0;
        input [31:0] w;
        logic [31:0] res1,res2,res3;
        res1 = rightrotate(w, 7);
        res2 = rightrotate(w,18);
        res3 = rightshift(w,3);
        sigma0 = res1 ^ res2 ^ res3;
    endfunction
    
	
	// Word generation phases:
	// - First 16 words: Direct message block extraction
	// - Remaining 48 words: Sigma-mixed combinations

    logic [6:0] j = 'd0; 
    logic [5:0] count;
    logic [6:0] k = 'd0;
    int unsigned i;
    
    assign count = j[5:0];
    
    always@(posedge clk) // j counter
        j <= j + 1;

    always@ (posedge clk)
    begin
        if (!j[6] && count < 'd16) begin
            Word[32*count +: 32] <= in[32*count +: 32];
            trigger <= 1;
        end
        else if(j == 'd65) begin
            trigger <= 0;
            j <= 'd0;
        end
        else if(!j[6] && ('d15 < j)) begin 
            Word[32*count +: 32] <= sigma1(Word[32*(count-2) +: 32]) + Word[32*(count-7) +: 32] + sigma0(Word[32*(count-15) +: 32]) + Word[32*(count-16) +: 32];
            trigger <= 1;
        end
    end
       
    // Output logic
    always@ (posedge clk)
    begin
        if(!k[6] && trigger) begin
            W <= Word[32*k +: 32];
            k <= k + 1;
        end
    end
    
endmodule
