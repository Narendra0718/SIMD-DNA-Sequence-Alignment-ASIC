`timescale 1ns/1ps
module simd_pe_array(
    input  signed [127:0] prev_row,
    input  signed [127:0] match_scores,
    input  signed [7:0]   gap_penalty,
    output signed [127:0] new_row,
    output        [31:0]  dir_row
);
    genvar i;
    wire signed [7:0] left_score [0:15];
    wire [1:0] dir [0:15];

    generate
        for (i = 0; i < 16; i = i+1) begin : pe_gen

         
            wire signed [7:0] diag  = (i == 0) ? 8'sd0
                                                : prev_row[127-((i-1)*8) -: 8];
            wire signed [7:0] up    = prev_row[127-(i*8) -: 8];

            wire signed [7:0] left  = (i == 0) ? 8'sd0 : left_score[i-1];

            simd_pe PE (
                .diag_score (diag),
                .up_score   (up),
                .left_score (left),
                .match_score(match_scores[127-(i*8) -: 8]),
                .gap_penalty(gap_penalty),
                .cell_score (left_score[i]),
                .direction  (dir[i])
            );

            assign new_row[127-(i*8) -: 8] = left_score[i];
            assign dir_row[31-(i*2)   -: 2] = dir[i];
        end
    endgenerate
endmodule


