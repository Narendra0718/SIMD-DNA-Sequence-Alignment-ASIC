`timescale 1ns/1ps
module direction_buffer(
    input clk,
    input rst,
    input load,
    input [31:0] dir_row,
    output reg [511:0] dir_mem
);
    always @(posedge clk or posedge rst) begin
        if(rst)
            dir_mem <= 0;
        else if(load)
            dir_mem <= {dir_mem[479:0], dir_row};
    end
endmodule
