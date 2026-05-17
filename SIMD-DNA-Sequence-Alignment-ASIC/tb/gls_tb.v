`timescale 1ns/1ps
module tb_top_simd_alignment;
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;

    reg rst, start;
    reg [127:0] ref_bases, sample_bases;
    
    wire signed [7:0] max_score;
    wire [7:0] mutations;
    wire tb_done;
    top_simd_alignment DUT(
        .clk(clk), 
        .rst(rst), 
        .start(start),
        .ref_bases(ref_bases), 
        .sample_bases(sample_bases),
        .max_score(max_score), 
        .mutations(mutations), 
        .done(tb_done)
    );

    initial begin
        rst = 1; start = 0;
        #20 rst = 0;

        ref_bases = {"A","C","G","T", "A","C","G","T", "A","C","G","T", "A","C","G","T"};
        sample_bases = {"A","C","G","A", "A","C","G","T", "A","C","G","T", "A","C","C","T"};

        #10 start = 1;
        #10 start = 0;
 wait(tb_done);
        #200; 
        
        $display("=================================");
        $display("FINAL GATE-LEVEL RESULTS");
        $display("---------------------------------");
        $display("MAX SCORE  = %d", max_score); 
        $display("MUTATIONS  = %d", mutations); 
        $display("=================================");
        #50 $finish;
    end
endmodule
