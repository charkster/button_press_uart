module trigger_uart_top (
  input  logic clk_27mhz,
  input  logic button_s1,
  input  logic button_s2,
  input  logic uart_rx,
  output logic uart_tx,
  output logic uart_rx_buf,
  output logic uart_tx_buf
);

  logic rst_n;
  logic clk_100mhz;
  logic rst_n_sync;
  logic button_press_sync;
  logic button_press_sync_hold;
  logic button_press_redge;

  // this can be used to observe with a logic analyzer
  assign uart_rx_buf = uart_rx;
  assign uart_tx_buf = uart_tx;

  // generate 100mhz clock, actual frequency is 100.2 MHz
  Gowin_rPLL_100mhz u_Gowin_rPLL_100mhz
    ( .clkout (clk_100mhz), 
      .clkin  (clk_27mhz)
     );

  assign rst_n = button_s1;

  synchronizer u_synchronizer_rst_n_sync
    ( .clk      (clk_100mhz), // input
      .rst_n    (rst_n),      // input
      .data_in  (1'b1),       // input
      .data_out (rst_n_sync)  // output
     );

  // active high button press (button_s2 is normally high)
  synchronizer u_synchronizer_button_press_sync
    ( .clk      (clk_100mhz),       // input
      .rst_n    (rst_n),            // input
      .data_in  (~button_s2),       // input
      .data_out (button_press_sync) // output
     );

  // rising edge detect
  always_ff @(posedge clk_100mhz, negedge rst_n_sync)
    if (~rst_n_sync) button_press_sync_hold <= 1'b0;
    else             button_press_sync_hold <= button_press_sync;

  assign button_press_redge = button_press_sync && (~button_press_sync_hold);

  button_press u_button_press
    ( .clk_100mhz,
      .rst_n_sync,
      .button_press_redge,
      .uart_rx,
      .uart_tx
     );

endmodule