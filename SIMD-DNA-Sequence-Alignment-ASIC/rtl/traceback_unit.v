`timescale 1ns/1ps
module traceback_unit(
    input clk, rst, start,
    input [511:0] dir_mem,
    input [127:0] ref_bases,
    input [127:0] sample_bases,
    input [3:0] max_i,
    input [3:0] max_j,
    output reg [7:0] matches,
    output reg [7:0] mismatches,
    output reg [7:0] insertions,
    output reg [7:0] deletions,
    output reg done
);
    reg [3:0] i,j;
    reg running;
    reg [1:0] dir;

    function [1:0] get_dir;
        input [3:0] r,c;
        begin
           
            get_dir = dir_mem[((15-r)*32) + (31-(c*2)) -: 2];
        end
    endfunction

    function [7:0] get_ref;
        input [3:0] idx;
        get_ref = ref_bases[127-(idx*8) -:8];
    endfunction

    function [7:0] get_sample;
        input [3:0] idx;
        get_sample = sample_bases[127-(idx*8) -:8];
    endfunction

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            matches <= 0; mismatches <= 0; insertions <= 0;
            deletions <= 0; done <= 0; running <= 0;
        end
        else if(start) begin
            i <= max_i; j <= max_j;
            running <= 1; done <= 0;
        end
        else if(running) begin
            dir = get_dir(i,j);
            
            if (dir == 2'b00) begin
                running <= 0; done <= 1;
            end else begin
                case(dir)
                    2'b01: begin // DIAG (Match/Mismatch)
                        if(get_ref(j) == get_sample(i)) matches <= matches + 1;
                        else mismatches <= mismatches + 1;
                        
                        if (i == 0 || j == 0) begin running <= 0; done <= 1; end 
                        else begin i <= i - 1; j <= j - 1; end
                    end
                    2'b10: begin // UP (Extra sample base -> Insertion)
                        insertions <= insertions + 1;
                        if (i == 0) begin running <= 0; done <= 1; end 
                        else i <= i - 1;
                    end
                    2'b11: begin // LEFT (Missing sample base -> Deletion)
                        deletions <= deletions + 1;
                        if (j == 0) begin running <= 0; done <= 1; end 
                        else j <= j - 1;
                    end
                    default: begin running <= 0; done <= 1; end
                endcase
            end
        end
    end
endmodule
