module single_cycle_arbiter #(
  parameter N = 32
) (
  input   logic          clk,
  input   logic          reset,
  input   logic [N-1:0]  req_i,
  output  logic [N-1:0]  gnt_o
);

  // Write your logic here...
  logic[N-1:0] priority_req;
  
  assign priority_req[0] = 1'b0;
  for(genvar i = 0; i < N-1; i++) begin
    assign priority_req[i+1] = priority_req[i] | req_i[i];
  end
  
  assign gnt_o = req_i & ~ priority_req;

endmodule

