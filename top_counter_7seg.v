// top_counter_7seg.v : counter FSM + 7-segment decoder
module top_counter_7seg (
    input        clk,
    input        reset,
    input        run,
    output [3:0] count,
    output [6:0] seg
);
    counter_fsm u_cnt (.clk(clk), .reset(reset), .run(run), .count(count));
    seg_decoder u_dec (.count(count), .seg(seg));
endmodule
