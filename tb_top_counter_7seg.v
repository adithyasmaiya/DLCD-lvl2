`timescale 1ns/1ps
module tb_top_counter_7seg;
    reg clk = 0, reset = 1, run = 0;
    wire [3:0] count;
    wire [6:0] seg;
    integer errors = 0, i;
    reg [3:0] prev;
    reg [6:0] exp_seg [0:15];

    top_counter_7seg dut (.clk(clk), .reset(reset), .run(run), .count(count), .seg(seg));

    always #5 clk = ~clk;

    initial begin
        exp_seg[0]=7'h3F; exp_seg[1]=7'h06; exp_seg[2]=7'h5B; exp_seg[3]=7'h4F;
        exp_seg[4]=7'h66; exp_seg[5]=7'h6D; exp_seg[6]=7'h7D; exp_seg[7]=7'h07;
        exp_seg[8]=7'h7F; exp_seg[9]=7'h6F; exp_seg[10]=7'h77; exp_seg[11]=7'h7C;
        exp_seg[12]=7'h39; exp_seg[13]=7'h5E; exp_seg[14]=7'h79; exp_seg[15]=7'h71;
    end

    // 7-seg always matches count
    always @(count or seg) #1
        if (seg !== exp_seg[count]) begin
            errors = errors + 1;
            $display("FAIL: seg mismatch count=%h seg=%b", count, seg);
        end

    initial begin
        $dumpfile("counter.vcd"); $dumpvars(0, tb_top_counter_7seg);
        $monitor("t=%0t reset=%b run=%b count=%h seg=%b", $time, reset, run, count, seg);

        // reset
        @(negedge clk); @(negedge clk); reset = 0;

        // TEST 1: count increases while run=1 (incl. wrap 15 -> 0, over 20 clocks)
        run = 1;
        for (i = 0; i < 20; i = i + 1) begin
            prev = count;
            @(negedge clk);
            if (count !== (prev + 4'd1)) begin
                errors = errors + 1;
                $display("FAIL: run=1 expected %h got %h", prev + 4'd1, count);
            end
            if (prev == 4'hF && count !== 4'h0) begin
                errors = errors + 1; $display("FAIL: wrap");
            end
            if (prev == 4'hF && count === 4'h0) $display("PASS: wrap 1111 -> 0000");
        end

        // TEST 2: count holds while run=0
        run = 0; @(negedge clk); prev = count;
        repeat (6) begin
            @(negedge clk);
            if (count !== prev) begin
                errors = errors + 1; $display("FAIL: hold changed %h -> %h", prev, count);
            end
        end
        $display("PASS: hold check done (count=%h)", count);

        // TEST 3: resume, then synchronous reset
        run = 1; repeat (3) @(negedge clk);
        reset = 1; @(negedge clk);
        if (count !== 4'h0) begin errors = errors + 1; $display("FAIL: reset"); end
        reset = 0;

        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
