`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds(led_clk,ledrst,ledwrite,ledaddrcs, ledaddr, ledwdata,ledout);
  input led_clk,ledrst;
  input ledwrite;
  input ledaddrcs;
  input[15:0] ledwdata;
  input[1:0] ledaddr;
  output[23:0] ledout;

  reg [23:0] ledout;

  always@(posedge led_clk or posedge ledrst) begin
    if (ledrst) 
      ledout = 16'h0000;
    else if (ledwrite && ledaddrcs) begin
      if (ledaddr[1]) // 62
        ledout[23:16] = ledwdata[7:0];
      else
        ledout[15:0] = ledwdata;
    end
  end
endmodule
