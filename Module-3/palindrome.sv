module palindrome3b (
  input   logic        clk,
  input   logic        reset,

  input   logic        x_i,

  output  logic        palindrome_o
);

  // Write your logic here...
  logic [1:0] count_q;
  logic [1:0] nxt_count;
  
  logic [1:0] shift_reg_q;
  logic [1:0] nxt_shift_reg;
  
  always_ff @(posedge clk or posedge reset)
    if(reset) begin
      count_q <= 2'b00;
      shift_reg_q <= 2'b00;
    end else begin
      count_q <= nxt_count;
      shift_reg_q <= nxt_shift_reg;
    end
  
  assign nxt_count = count_q[1] ? count_q : count_q + 2'b01;
  assign nxt_shift_reg = {shift_reg_q[0], x_i};
  assign palindrome_o = (x_i == shift_reg_q[1]) & count_q[1];
  
endmodule
