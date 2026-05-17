`timescale 1ns/1ps
module tb_top_simd_alignment;
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;

    reg rst, start;
    reg [127:0] ref_bases, sample_bases;
    wire signed [7:0] max_score;
    wire [7:0] mutations;
    wire done;

    top_simd_alignment DUT(
        .clk(clk), .rst(rst), .start(start),
        .ref_bases(ref_bases), .sample_bases(sample_bases),
        .max_score(max_score), .mutations(mutations), .done(done)
    );

    wire [7:0] matches = DUT.TB.matches;
    wire [7:0] mismatches = DUT.TB.mismatches;
    wire [7:0] insertions = DUT.TB.insertions;
    wire [7:0] deletions = DUT.TB.deletions;
    wire tb_done = DUT.TB.done;

    initial begin
        rst = 1; start = 0;
        #20 rst = 0;

       
        ref_bases = {"A","C","G","T", "A","C","G","T", "A","C","G","T", "A","C","G","T"};
        sample_bases = {"A","C","G","A", "A","C","G","T", "A","C","G","T", "A","C","C","T"};

        #10 start = 1;
        #10 start = 0;

        wait(tb_done);
        
        $display("=================================");
        $display("FINAL RESULTS");
        $display("---------------------------------");
        $display("MAX SCORE  = %d", max_score); 
        $display("MATCHES    = %d", matches);   
        $display("MISMATCHES = %d", mismatches); 
        $display("INSERTIONS = %d", insertions); 
        $display("DELETIONS  = %d", deletions);  
        $display("MUTATIONS  = %d", mutations); 
        $display("=================================");
        #50 $finish;
    end
endmodule
