module seq_generator (
  input   logic        clk,
  input   logic        reset,

  output  logic [31:0] seq_o
);

  // Write your logic here...
  logic[31:0] seq_t1;
  logic[31:0] seq_t2;
  logic[31:0] seq_t3;
  logic[31:0] seq_nxt;
  
  always_ff @(posedge clk or posedge reset)
    if(reset) begin 
      seq_t3 <= 32'h0;
      seq_t2 <= 32'h1;
      seq_t1 <= 32'h1;
    end else begin
      seq_t3 <= seq_t2;
      seq_t2 <= seq_t1;
      seq_t1 <= seq_nxt;
    end
  
  assign seq_nxt[31:0] = seq_t3[31:0] + seq_t2[31:0];
  assign seq_o[31:0] = seq_t3[31:0];
endmodule
