`timescale 1ns/1ps
module top_simd_alignment( input clk, rst, start, input [127:0] ref_bases, input [127:0] sample_bases, output signed [7:0] max_score, output [7:0] mutations, output done );
wire load_row;
wire [127:0] prev_row, new_row;
wire signed [127:0] match_scores;
wire signed [7:0] gap_penalty;
wire [31:0] dir_row;
wire [511:0] dir_mem;
reg [127:0] sample_shift;

wire [3:0] max_i, max_j; 

always @(posedge clk or posedge rst) begin
    if(rst)
        sample_shift <= 0;
    else if(start)
        sample_shift <= sample_bases;
    else if(load_row)
        sample_shift <= sample_shift << 8;
end

genvar i;
generate
    for(i=0; i<16; i=i+1) begin : scoring_gen
        scoring_unit S(
            .ref_base(ref_bases[127-(i*8)-:8]),
            .sample_base(sample_shift[127:120]),
            .match_score(match_scores[127-(i*8)-:8])
        );
    end
endgenerate

gap_penalty_unit GAP(.gap_penalty(gap_penalty));

dp_row_buffer BUF(
    .clk(clk), .rst(rst), 
    .load(load_row), 
    .new_row(new_row), 
    .prev_row(prev_row)
);

simd_pe_array ARRAY(
    .prev_row(prev_row), 
    .match_scores(match_scores), 
    .gap_penalty(gap_penalty), 
    .new_row(new_row), 
    .dir_row(dir_row)
);

direction_buffer DIRBUF(
    .clk(clk), .rst(rst), 
    .load(load_row), 
    .dir_row(dir_row), 
    .dir_mem(dir_mem)
);

max_score_tracker MAX(
    .clk(clk), .rst(rst), 
    .load_row(load_row), 
    .cell_scores(new_row), 
    .max_score(max_score),
    .max_i(max_i),       
    .max_j(max_j)        
);

simd_controller CTRL(
    .clk(clk), .rst(rst), 
    .start(start), 
    .load_row(load_row), 
    .done(done)
);

wire [7:0] matches, mismatches, ins, del;
wire tb_done;

traceback_unit TB(
    .clk(clk), .rst(rst), 
    .start(done), 
    .dir_mem(dir_mem), 
    .ref_bases(ref_bases), 
    .sample_bases(sample_bases), 
    .max_i(max_i),       
    .max_j(max_j),       
    .matches(matches), 
    .mismatches(mismatches), 
    .insertions(ins), 
    .deletions(del), 
    .done(tb_done)
);

assign mutations = mismatches + ins + del; 
endmodule
