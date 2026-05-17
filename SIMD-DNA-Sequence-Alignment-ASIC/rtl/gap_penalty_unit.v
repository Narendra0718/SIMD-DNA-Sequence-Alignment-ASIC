`timescale 1ns/1ps
module gap_penalty_unit(
    output signed [7:0] gap_penalty
);
    parameter GAP_PENALTY = -8'sd2;
    assign gap_penalty = GAP_PENALTY;
endmodule
