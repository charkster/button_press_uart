
module button_press (
  input  logic clk_100mhz,
  input  logic rst_n_sync,
  input  logic button_press_redge,
  input  logic uart_rx,
  output logic uart_tx
);

  logic       send_trig;
  logic [7:0] send_data;
  logic       data_valid;
  logic [9:0] fast_counter;
  logic [7:0] counter_10us;

  assign send_trig = button_press_redge || data_valid;
  assign send_data = (counter_10us > 'd0) ? counter_10us : 8'h88;

  uart_tx 
  # ( .SYSCLOCK( 100.0 ), .BAUDRATE( 3.0 ) ) // MHz and Mbits
  u_uart_tx
    ( .clk       (clk_100mhz), // input
      .rst_n     (rst_n_sync), // input
      .send_trig,              // input
      .send_data,              // input [7:0]
      .tx        (uart_tx),    // output
      .tx_bsy    ()            // output
     );

  uart_rx
  # ( .SYSCLOCK( 100.0 ), .BAUDRATE( 3.0 ) ) // MHz and Mbits
  u_uart_rx
    ( .clk           (clk_100mhz), // input
      .rst_n         (rst_n_sync), // input
      .rx            (uart_rx),    // input
      .rx_bsy        (),           // output
      .block_timeout (),           // output
      .data_valid,                 // output
      .data_out      ()            // output [7:0]
     );

  always_ff @(posedge clk_100mhz, negedge rst_n_sync)
    if (~rst_n_sync)                 fast_counter <= 'd0;
    else if ((button_press_redge) || (fast_counter == 'd1000)) fast_counter <= 'd1;
    else if ((fast_counter > 'd0) && (counter_10us != 'd255))  fast_counter <= fast_counter + 1;

  always_ff @(posedge clk_100mhz, negedge rst_n_sync)
    if (~rst_n_sync)                 counter_10us <= 'd0;
    else if (button_press_redge)     counter_10us <= 'd0;
    else if (fast_counter == 'd1000) counter_10us <= counter_10us + 1;


endmodule