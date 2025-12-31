module credit_n_deadlock (
  input   logic        clk,
  input   logic        reset,

  // RX side interface
  input   logic        rx_valid_i,
  input   logic [2:0]  rx_id_i,
  input   logic [4:0]  rx_payload_i,
  input   logic        rx_credit_i,
  output  logic        rx_ready_o,
  output  logic        rx_retry_o,

  // TX side interface
  output  logic        tx_valid_o,
  output  logic [2:0]  tx_id_o,
  output  logic [4:0]  tx_payload_o,
  input   logic        tx_ready_i,

  // Credit interface
  output  logic        credit_gnt_o,
  output  logic [2:0]  credit_id_o

);

  // Write your logic here
  logic               rx_fifo_push;
  logic               rx_fifo_pop;      
  logic [2:0]         rx_fifo_pop_id;
  logic [4:0]         rx_fifo_pop_data;
  logic               rx_fifo_full;
  logic               rx_fifo_empty;
  logic               rx_fifo_stalled;

  logic               rx_ready;
  logic               rx_retry;

  logic               rx_retried_req;

  logic [1:0]         deadlock_count_q;
  logic [1:0]         nxt_deadlock_count;
  logic               deadlock_en;

  logic               tx_valid;
  logic [2:0]         tx_id;
  logic [4:0]         tx_payload;
  logic               tx_free;
  logic               tx_ready;

  logic               retry_fifo_pop;
  logic [2:0]         retry_fifo_pop_data;
  logic               retry_fifo_empty;

  logic [2:0]         rsv_count_q;
  logic [2:0]         nxt_rsv_count;
  logic               rsv_count_incr;
  logic               rsv_count_decr;
  logic               rsv_count_max;

  qs_fifo #(.DEPTH(4), .DATA_W(8)) rx_fifo (
    .clk          (clk),
    .reset        (reset),

    .push_i       (rx_fifo_push),
    .push_data_i  ({rx_id_i, rx_payload_i}),

    .pop_i        (rx_fifo_pop),
    .pop_data_o   ({rx_fifo_pop_id, rx_fifo_pop_data}),

    .full_o       (rx_fifo_full),
    .empty_o      (rx_fifo_empty)
  );

  assign rx_retried_req = rx_valid_i & rx_credit_i;

  assign rx_fifo_push = (rx_valid_i & ~rsv_count_max) |
                        (rx_retried_req);
  assign rx_fifo_pop = tx_free & ~rx_fifo_empty;
  assign rx_ready = ~rsv_count_max | rx_retried_req;
  assign rx_fifo_stalled = rx_valid_i & rsv_count_max;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      deadlock_count_q <= 2'h0;
    else
      deadlock_count_q <= nxt_deadlock_count;

  assign deadlock_en = (deadlock_count_q == 2'b10);
  assign nxt_deadlock_count = rx_fifo_pop     ? 2'h0 :
                              deadlock_en     ? deadlock_count_q :
                              rx_fifo_stalled ? deadlock_count_q + 2'b01 :
                                                deadlock_count_q;

  
  assign rx_retry = deadlock_en & rx_fifo_stalled & ~rx_credit_i;

  qs_fifo #(.DEPTH(4), .DATA_W(3)) retry_fifo (
    .clk          (clk),
    .reset        (reset),

    .push_i       (rx_retry),
    .push_data_i  (rx_id_i),

    .pop_i        (retry_fifo_pop),
    .pop_data_o   (retry_fifo_pop_data),

    .full_o       (/* Not needed */),
    .empty_o      (retry_fifo_empty)
  );

  assign retry_fifo_pop = ~retry_fifo_empty & rx_fifo_pop;

  assign tx_valid   = ~rx_fifo_empty;
  assign tx_id      = rx_fifo_pop_id;
  assign tx_payload = rx_fifo_pop_data;

  qs_skid_buffer #(.DATA_W(8)) tx_skid_buffer (
    .clk        (clk),
    .reset      (reset),

    .i_valid_i  (tx_valid),
    .i_data_i   ({tx_id, tx_payload}),
    .i_ready_o  (tx_ready),

    .e_valid_o  (tx_valid_o),
    .e_data_o   ({tx_id_o, tx_payload_o}),
    .e_ready_i  (tx_ready_i)

  );

  assign tx_free = tx_ready;

  assign credit_gnt_o = retry_fifo_pop;
  assign credit_id_o  = retry_fifo_pop_data;

  always_ff @(posedge clk or posedge reset)
    if (reset)
      rsv_count_q <= 3'h0;
    else
      rsv_count_q <= nxt_rsv_count;

  assign nxt_rsv_count = (rsv_count_incr & rsv_count_decr) ? rsv_count_q :
                         (rsv_count_incr)                  ? (rsv_count_q + 3'h1) :
                         (rsv_count_decr)                  ? (rsv_count_q - 3'h1) :
                                                             (rsv_count_q);

  assign rsv_count_incr = (rx_fifo_push & ~rx_credit_i) |
                          (retry_fifo_pop);

  assign rsv_count_decr = rx_fifo_pop;

  assign rsv_count_max  = (rsv_count_q == 3'h4);

  assign rx_ready_o = rx_ready;
  assign rx_retry_o = rx_retry;


endmodule
