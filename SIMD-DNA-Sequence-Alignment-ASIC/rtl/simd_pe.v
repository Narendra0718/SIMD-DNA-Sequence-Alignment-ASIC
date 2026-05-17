`timescale 1ns/1ps
module simd_pe(
    input signed [7:0] diag_score,
    input signed [7:0] up_score,
    input signed [7:0] left_score,
    input signed [7:0] match_score,
    input signed [7:0] gap_penalty,
    output reg signed [7:0] cell_score,
    output reg [1:0] direction
);
    reg signed [7:0] d,u,l;
    
    always @(*) begin
        d = diag_score + match_score;
        u = up_score + gap_penalty;
        l = left_score + gap_penalty;
        
        cell_score = 0;
        direction = 2'b00;
        
        if(d >= u && d >= l && d > 0) begin
            cell_score = d;
            direction = 2'b01;
        end
        else if(u >= l && u > 0) begin
            cell_score = u;
            direction = 2'b10;
        end
        else if(l > 0) begin
            cell_score = l;
            direction = 2'b11;
        end
    end
endmodule
