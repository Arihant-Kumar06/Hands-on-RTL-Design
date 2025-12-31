module one_shot (
  input   logic        clk,
  input   logic        reset,

  input   logic        data_i,

  output  logic        shot_o

);

  // Write your logic here
	 logic data_q;

  always_ff @(posedge clk or posedge reset)
    if (reset) begin
      data_q <= 1'b0;
    end else begin
      data_q <= data_i;
    end

  assign shot_o = data_i & ~data_q;

  
endmodule
