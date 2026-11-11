// counter_fsm.v : 2-state Moore FSM (RUN/HOLD) + 4-bit counter
module counter_fsm (
    input            clk,
    input            reset,   // synchronous, active high
    input            run,
    output reg [3:0] count
);
    localparam HOLD = 1'b0, RUN = 1'b1;

    reg  state, next_state;
    wire [3:0] count_inc = count + 4'd1;   // wraps 1111 -> 0000
    wire [3:0] next_count;

    // Next-state logic (transition labels: run=1 -> RUN, run=0 -> HOLD,
    // including self-loops RUN--run=1-->RUN and HOLD--run=0-->HOLD)
    always @(*) next_state = run ? RUN : HOLD;

    // 2-to-1 MUX feeding the D inputs of the 4 flip-flops
    assign next_count = (next_state == RUN) ? count_inc : count;

    // State + count registers
    always @(posedge clk) begin
        if (reset) begin
            state <= HOLD;
            count <= 4'b0000;
        end else begin
            state <= next_state;
            count <= next_count;
        end
    end
endmodule
