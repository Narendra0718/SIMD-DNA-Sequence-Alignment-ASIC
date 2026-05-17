`timescale 1ns/1ps
module simd_controller(
    input clk,
    input rst,
    input start,
    output reg load_row,
    output reg done
);
    reg [4:0] count;
    reg running;
    reg wait_cycle; // 2-cycle latency for 100MHz operation

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count <= 0;
            running <= 0;
            load_row <= 0;
            done <= 0;
            wait_cycle <= 0;
        end
        else if(start) begin
            running <= 1;
            count <= 16; 
            done <= 0;
            load_row <= 0;
            wait_cycle <= 1; 
        end
        else if(running) begin
            if(wait_cycle) begin
                wait_cycle <= 0;
                load_row <= 0;
            end
            else begin
               
                if(count == 0) begin
                    running <= 0;
                    done <= 1;
                    load_row <= 0; 
                end
                else begin
                    load_row <= 1;
                    wait_cycle <= 1; 
                    count <= count - 1;
                end
            end
        end
        else begin
            load_row <= 0;
            done <= 0;
        end
    end
endmodule

