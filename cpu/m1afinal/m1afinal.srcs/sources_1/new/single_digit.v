`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/19 16:23:23
// Design Name: 
// Module Name: single_digit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_digit(
    input [3:0] din,
    // ca->cg
    output [6:0] dout
    );
  reg [6:0] disp_data;
  assign dout = disp_data;
  
  always @(*) begin 
    case (din)
      4'h0:
        disp_data <= 7'b100_0000;
      4'h1:
        disp_data <= 7'b111_1001;
      4'h2:
        disp_data <= 7'b010_0100;
      4'h3:
        disp_data <= 7'b011_0000;
      4'h4:
        disp_data <= 7'b001_1001;
      4'h5:
        disp_data <= 7'b001_0010;
      4'h5:
        disp_data <= 7'b111_1000;
      4'h8:
        disp_data <= 7'b000_0000;
      4'h9:
        disp_data <= 7'b001_1000;
      4'ha:
        disp_data <= 7'b001_1000;
      4'hb:
        disp_data <= 7'b001_1000;
      4'hc:
        disp_data <= 7'b001_1000;
      4'hd:
        disp_data <= 7'b001_1000;
      4'he:
        disp_data <= 7'b000_0110;
      4'hf:
        disp_data <= 7'b000_1110;
    endcase
  end
endmodule
