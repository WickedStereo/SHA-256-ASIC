//////////////////////////////////////////////////////////////////////////////////
// Module: core_pipe
// Function: SHA-256 Compression Pipeline
// Pipeline:
//   7-Stage State Machine (INIT → PIPE_BEG_1_STAGE → ... → OUTPUT)
// Parameters:
//   NUM_ROUNDS = 64 - Compression rounds
// Ports:
//   clk    - System clock
//   reset  - Active-high reset
//   W      - Scheduled word input [31:0]
//   Hin    - Initial hash value [255:0]  
//   H_out  - Final hash output [255:0]
// Operations:
//   - maj: Majority function (FIPS 4.1.2)
//   - ch:  Choose function (FIPS 4.1.2)
//   - Σ0/Σ1: Rotation mixes
//////////////////////////////////////////////////////////////////////////////////

// 7-Stage Pipeline:
// INIT            : Reset state
// PIPE_BEG_1_STAGE: Initial register setup
// FULL_PIP_3_STAGE: Core computation (64 rounds)
// OUTPUT          : Final hash combination


module core_pipe (
    input clk,
    input reset,    
    input block_count,
    input ready,
    input [0:63][31:0] W,
    input [255:0] H_in,
    output logic [255:0] H_out,
    output logic trigger

);

    parameter INIT              = 0,
              PIPE_BEG_1_STAGE  = 1,
              PIPE_BEG_2_STAGE  = 2,
              FULL_PIP_3_STAGE  = 3,
              PIPE_END_2_STAGE  = 4,
              PIPE_END_1_STAGE  = 5,
              OUTPUT_STAGE      = 6;
    
    parameter a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h =7;


    logic [0:2047] K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};


    logic [8:0] counter;
    logic [3:0] state, next_state;
    logic [0:7][31:0] result, new_result; 
    logic [31:0] M, L;
    logic update_M, update_L;
    logic update_a, update_b, update_c, update_d, update_e, update_f, update_g, update_h;
    logic [31:0] w, k;
    logic [31:0] new_a, new_e, new_M, new_L;
    logic [31:0] mux_1, mux_2;

    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 9'd0;
            state <= INIT;
            result[0] <= 32'h6a09e667;
            result[1] <= 32'hbb67ae85;
            result[2] <= 32'h3c6ef372;
            result[3] <= 32'ha54ff53a;
            result[4] <= 32'h510e527f;
            result[5] <= 32'h9b05688c;
            result[6] <= 32'h1f83d9ab;
            result[7] <= 32'h5be0cd19;

            M <= 0;
            L <= 0;
        end
        else if (ready) begin
            counter <= counter + 9'd1;
            state <= next_state;
            result <= new_result;
            if (update_M) M <= new_M;
            if (update_L) L <= new_L;
        end
    end

    always_comb begin
        if (ready) begin
            case (state)
                INIT:begin
                    next_state = PIPE_BEG_1_STAGE;
                    new_result = result;
                    update_M = 0;
                    update_L = 0;
                end
                PIPE_BEG_1_STAGE: begin
                    next_state = PIPE_BEG_2_STAGE;
                    update_M = 1;
                    update_L = 0;
                end
                PIPE_BEG_2_STAGE: begin
                    next_state = FULL_PIP_3_STAGE;
                    //new_result[4:7] = {new_e, result[4:6]};
                    new_result[4] = new_e;
                    new_result[5] = result[4];
                    new_result[6] = result[5];
                    new_result[7] = result[6];
                    update_M = 1;
                    update_L = 1;
                end
                FULL_PIP_3_STAGE: begin
                    if (counter < 9'd64) next_state = FULL_PIP_3_STAGE;
                    else next_state = PIPE_END_2_STAGE;
                    {new_result[0],new_result[1],new_result[2],new_result[3],new_result[4],new_result[5],new_result[6],new_result[7]} = {new_a, result[0], result[1], result[2], new_e, result[4], result[5], result[6]};
                    update_M = 1;
                    update_L = 1;
                end
                PIPE_END_2_STAGE: begin
                    next_state = PIPE_END_1_STAGE;
                    {new_result[0],new_result[1],new_result[2],new_result[3],new_result[4],new_result[5],new_result[6],new_result[7]} = {new_a, result[0], result[1], result[2], new_e, result[4], result[5], result[6]};
                    update_M = 1;
                    update_L = 1;
                end
                PIPE_END_1_STAGE: begin
                    next_state = OUTPUT_STAGE;
                    {new_result[0], new_result[1], new_result[2], new_result[3]} = {new_a, new_result[0], new_result[1], new_result[2]};
                    update_M = 0;
                    update_L = 1;
                end
                OUTPUT_STAGE: begin
                    next_state = INIT;
                    update_M = 0;
                    update_L = 0;
                end
                default: begin
                    next_state = INIT;
                    update_M = 0;
                    update_L = 0;
                end
            endcase
        end
        else begin
            next_state = INIT;
            update_M = 0;
            update_L = 0;
        end
    end

    assign w = (counter <= 9'd64) ? W[counter - 1] : 0;
    assign k = (counter <= 9'd64) ? K[32*(counter - 1) +: 32] : 0;
    assign new_M = w + k + mux_2;
    assign new_L = S1(result[e]) + ch(result[e], result[f], result[g]) + M;
    assign new_a = S0(result[a]) + maj(result[a], result[b], result[c]) + L;
    assign new_e = mux_1 + S1(result[e]) + ch(result[e], result[f], result[g]) + M;
    assign mux_1 = (state <= 3'd2) ? result[3] : result[2];
    assign mux_2 = (state <= 3'd1) ? result[7] : result[6];
    
    assign trigger = counter == 9'd68;
    assign H_out = trigger ? {result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7]} + H_in : 0;


function automatic [31:0] ROTR;
    input [31:0] e;
    input int length;
    length = length % 32;
    ROTR = (e >> length)|(e << (32 - length));
endfunction

function automatic [31:0] S1;
    input [31:0] e;
    S1 = ROTR(e, 6) ^ ROTR(e, 11) ^ ROTR(e, 25);
endfunction

function automatic [31:0] S0;
    input [31:0] a;
    S0 = ROTR(a, 2) ^ ROTR(a, 13) ^ ROTR(a, 22);
endfunction

function automatic [31:0] ch;
    input [31:0] e;
    input [31:0] f;
    input [31:0] g;
    ch = (e & f) ^ ( (~e) & g);
endfunction

// Majority function (maj) from FIPS 180-4
function automatic [31:0] maj;
    input [31:0] a;
    input [31:0] b;
    input [31:0] c;
    maj = (a & b) ^ (a & c) ^ (b & c);
endfunction

endmodule