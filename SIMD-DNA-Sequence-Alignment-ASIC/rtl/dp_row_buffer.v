`timescale 1ns/1ps
module dp_row_buffer(
    input clk,
    input rst,
    input load,
    input [127:0] new_row,
    output reg [127:0] prev_row
);
    always @(posedge clk or posedge rst) begin
        if(rst)
            prev_row <= 128'd0;
        else if(load)
            prev_row <= new_row;
    end
endmodule
