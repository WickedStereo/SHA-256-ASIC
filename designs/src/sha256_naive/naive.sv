`timescale 1ns / 1ps

module naive (
    input clk,
    input reset,
    input block_count,
    input [31:0] W,
    input [255:0] H_in,
    output logic [255:0] H_out,
    output logic done
);      
    
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

    function automatic [31:0] S1;
        input [31:0] e;
        logic [31:0] res1,res2,res3;
        res1 = rightrotate(e, 6);
        res2 = rightrotate(e, 11);
        res3 = rightrotate(e, 25);
        S1 = res1 ^ res2 ^ res3;
    endfunction

    function automatic [31:0] S0;
        input [31:0] a;
        logic [31:0] res1,res2,res3;
        res1 = rightrotate(a, 2);
        res2 = rightrotate(a, 13);
        res3 = rightrotate(a, 22);
        S0 = res1 ^ res2 ^ res3;
    endfunction
    
    function automatic [31:0] ch;
        input [31:0] e;
        input [31:0] f;
        input [31:0] g;
        ch = (e & f) ^ ( (~e) & g);
    endfunction

    function automatic [31:0] maj;
        input [31:0] a;
        input [31:0] b;
        input [31:0] c;
        maj = (a & b) ^ (a & c) ^ (b & c);
    endfunction
     
    logic [31:0] new_a, new_b, new_c, new_d, new_e, new_f, new_g, new_h; //Working variables used in algorithm
    logic [0:63][31:0] K = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};


    logic [6:0] counter = 7'd0;       // 6-bit counter, 7th bit for considering the counter done
   
    logic [31:0] t1; 
    logic [31:0] t2;
    
    integer l = 0;
    //logic [255:0]H;
    logic trigger;
    logic [255:0] out;
    logic [31:0] n_a,n_b,n_c,n_d,n_e,n_f,n_g,n_h;
    
    // Counter till 64
    always@(posedge clk)
        begin
            if(reset)
                begin
                    new_a <= H_in[255:224];
                    new_b <= H_in[223:192];
                    new_c <= H_in[191:160];
                    new_d <= H_in[159:128];
                    new_e <= H_in[127:96];
                    new_f <= H_in[95:64];
                    new_g <= H_in[63:32];
                    new_h <= H_in[31:0];
                    
                    counter <= 7'd0;
                    l <= 0;
                    done <= 1;
                   
                end
            else
                begin
                    new_h <= new_g;
                    new_g <= new_f;
                    new_f <= new_e;
                    new_e <= new_d + t1;
                    new_d <= new_c;
                    new_c <= new_b;
                    new_b <= new_a;
                    new_a <= t1 + t2;
                    
                    counter <= counter + 7'd1;
                    l <= l + 1;
                end
        end
     
     // END logic   
     always@(posedge clk)
        begin 
            if((counter == 7'd63)||(l == 63))
                begin
                    counter <= 7'd0;
                    l <= 0;
                    trigger <= 1;
                    done <= 0;
                end
        end
     /*  
     // Multiple block logic
     always@(posedge clk)
     begin
        if (done) begin
            H <= H_out;
        end;
     end
     */
        
     assign t1 = S1(new_e) + ch(new_e,new_f,new_g) + new_h + W + K[l];
     assign t2 = S0(new_a) + maj(new_a,new_b,new_c);
     
     assign out = {new_a,new_b,new_c,new_d,new_e,new_f,new_g,new_h};
     
     assign n_a = (trigger) ? (new_a + H_in[255:224]) : 32'd0;
     assign n_b = (trigger) ? (new_b + H_in[223:192]) : 32'd0;
     assign n_c = (trigger) ? (new_c + H_in[191:160]) : 32'd0;
     assign n_d = (trigger) ? (new_d + H_in[159:128]) : 32'd0;
     assign n_e = (trigger) ? (new_e + H_in[127:96]) : 32'd0;
     assign n_f = (trigger) ? (new_f + H_in[95:64]) : 32'd0;
     assign n_g = (trigger) ? (new_g + H_in[63:32]) : 32'd0;
     assign n_h = (trigger) ? (new_h + H_in[31:0]) : 32'd0;
     
     assign H_out = {n_a,n_b,n_c,n_d,n_e,n_f,n_g,n_h};
     
endmodule