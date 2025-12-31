module edge_capture (
  input   logic        clk,
  input   logic        reset,

  input   logic [31:0] data_i,

  output  logic [31:0] edge_o

);

  // Write your logic here...
   
  logic [31:0] data_q;
  logic [31:0] edge_q;
  logic [31:0] data_next;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      data_q[31:0] <= 32'h0;
      edge_q[31:0] <= 32'h0;
    end else begin
      data_q[31:0] <= data_i[31:0];
      edge_q[31:0] <= data_next[31:0];
    end

  assign data_next[31:0] = (~data_i[31:0] & data_q[31:0]) |
                           (edge_q[31:0]);

  assign edge_o[31:0] = data_next[31:0];


endmodule
