`timescale 1ns/1ps
module scoring_unit(
    input [7:0] ref_base,
    input [7:0] sample_base,
    output reg signed [7:0] match_score
);
    parameter MATCH = 3;     
    parameter MISMATCH = -1;

    always @(*) begin
        if(ref_base == sample_base)
            match_score = MATCH;
        else
            match_score = MISMATCH;
    end
endmodule
