`timescale 1ns/1ps
module max_score_tracker(
    input clk,
    input rst,
    input load_row,
    input signed [127:0] cell_scores,
    output reg signed [7:0] max_score,
    output reg [3:0] max_i,
    output reg [3:0] max_j
);
    integer i;
    reg signed [7:0] current_max;
    reg [3:0] current_max_j;
    reg [3:0] row_count;
    reg signed [7:0] lane_score;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            max_score <= 0;
            row_count <= 0;
            max_i <= 0;
            max_j <= 0;
        end
        else if(load_row) begin
            current_max = max_score;
            current_max_j = max_j;
            
            
            for(i=0; i<16; i=i+1) begin
                lane_score = cell_scores[127-(i*8)-:8];
                if(lane_score > current_max) begin
                    current_max = lane_score;
                    current_max_j = i[3:0];
                end
            end
            
          
            if(current_max > max_score) begin
                max_score <= current_max;
                max_i <= row_count;
                max_j <= current_max_j;
            end
            
            row_count <= row_count + 1;
        end
    end
endmodule
