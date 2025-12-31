module two_pulses (
  input   logic       clk,
  input   logic       reset,

  input   logic       x_i,
  input   logic       y_i,

  output  logic       p_o

);

  logic [1:0] y_count_q;
  logic [1:0] nxt_y_count;

  logic       x_q;
  logic       x_en;

  logic       p;
  logic       p_q;
  logic       p_en;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      y_count_q <= 2'h0;
    else
      y_count_q <= nxt_y_count;

  always_comb begin
    nxt_y_count = y_count_q;
    if (x_i) begin
      nxt_y_count = 2'(y_i);
    end else if (y_i) begin
      case (y_count_q)
        2'b00,
        2'b01,
        2'b10 : nxt_y_count = y_count_q + 2'b01;
        2'b11 : nxt_y_count = y_count_q;
      endcase
    end
  end

  always_ff @(posedge clk or posedge reset)
    if (reset)
      x_q <= 1'b0;
    else if (x_en)
      x_q <= x_i;

  assign x_en = ~x_q & x_i;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      p_q <= 1'b0;
    else if (p_en)
      p_q <= p;

  assign p_en = x_i | y_i;

  assign p = ((x_q)          &        
             (x_i)           &        
             (y_count_q == 2'b10)) |  
             (p_q & ~y_i);            
                                      
  assign p_o = p;
endmodule
