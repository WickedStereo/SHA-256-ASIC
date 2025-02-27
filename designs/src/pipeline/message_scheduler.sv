//////////////////////////////////////////////////////////////////////////////////
// Module: message_scheduler
// Function: Message Schedule Generator
// Standard: NIST FIPS 180-4 §6.2.2
// Parameters:
//   BLOCK_SIZE = 512 - Input block size (bits)
// Ports:  
//   clk        - System clock
//   block_in	- Input block [BLOCK_SIZE-1:0]
//   block_out  - Scheduled block
// Features:
//   - 64-stage word generator
//   - Implements σ0/σ1 mixing functions
//////////////////////////////////////////////////////////////////////////////////

// Constraints
// Message Scheduler is designed for maximum 2 blocks. 
// Message scheduler can create maximum of 2 set of 64 words.


module message_scheduler(
    input clk,
    input reset,
    input ready,
    input [1:0] block_count,
    input [511:0] block_in,
    output logic done,
    output logic [0:63][31:0] block_out
    );
    
    logic [0:63][31:0]Word;
    logic [511:0] in;    
    logic [6:0] j = 0;  // Scheduler step counter
    logic [5:0] count;
//    logic [6:0] k = 0;  // Output index
    int unsigned i;
    
	// Word generation phases:
	// - First 16 words: Direct message block extraction
	// - Remaining 48 words: Sigma-mixed combinations
	
    assign in = block_in;
    assign count = j[5:0];

    always_ff @(posedge clk)
    begin
        if (reset || (j == 64) || ready) begin
            j <= 'd0;
        end
        else if (!done) begin
            if (count < 16) begin
                Word[count] <= in[512 - 32*(count+1) +: 32];     // Load first 16 words
                j <= j + 'd1;
            end
            else begin 
                Word[count] <= sigma1(Word[count - 2]) + Word[count - 7] + sigma0(Word[count - 15]) + Word[count - 16];
                j <= j + 'd1;
            end
       end        
    end
    
    always_comb begin
        if (reset || ready) begin
            block_out = 'd0;
            done = 0;
        end
        else if (j[6]) begin
            block_out = Word;
            done = 1;
        end
    end
    
    
    
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
    
    
endmodule