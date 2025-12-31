module perf_counters #(
  parameter CNT_W = 4
) (
  input  logic            clk,
  input  logic            reset,
  input  logic            sw_req_i,
  input  logic            cpu_trig_i,
  output logic[CNT_W-1:0] p_count_o
);

  // Write your logic here...
  logic [CNT_W-1:0] count_q;
  logic [CNT_W-1:0] count;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      count_q[CNT_W-1:0] <= {CNT_W{1'b0}};
    else
      count_q[CNT_W-1:0] <= count;

  always_comb begin
    count[CNT_W-1:0] = sw_req_i ? {{CNT_W-1{1'b0}}, cpu_trig_i} :
                                  count_q + {{CNT_W-1{1'b0}}, cpu_trig_i};
  end

  assign p_count_o[CNT_W-1:0] = sw_req_i ? count_q[CNT_W-1:0]: {CNT_W{1'b0}};


endmodule
