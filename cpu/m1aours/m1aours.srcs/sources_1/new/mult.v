`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/27 16:17:35
// Design Name: 
// Module Name: mult
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
`include "public.v"

module mult(
    input clk,
    input [31:0] data1,
    input [31:0] data2,
    input en,
    input is_signed,
    output reg [63:0] result,
    output reg is_valid
    );
    
  reg[4:0] count;
  reg [`WordRange] dataA_temp;
  reg [`WordRange] dataB_temp;
  wire[`DivMulResultRange] signed_result_wire;
  wire[`DivMulResultRange] unsigned_result_wire;
  always@(posedge clk, en)begin
      if(en == `Disable)begin
          count = 5'd0;
          dataA_temp = `ZeroWord;
          dataB_temp = `ZeroWord;
          is_valid <= `Disable;
      end else begin
          count = count + 5'd1;
          dataA_temp <= data1;
          dataB_temp <= data2;
          if(count == 5'd6)begin
              count = 0;
              is_valid <= `Enable;
              if (is_signed) begin
                  result <= signed_result_wire;
              end else begin
                  result <= unsigned_result_wire;
              end
          end
      end
  end
  
  signed_mult_5stage u_mul_signed(
  .CLK        (clk),
  .A          (dataA_temp),
  .B          (dataB_temp),
  .P          (signed_result_wire)
  );
  
  unsigned_mul_5stage u_mul_unsigned(
  .CLK        (clk),
  .A          (dataA_temp),
  .B          (dataB_temp),
  .P          (unsigned_result_wire)
  );

endmodule
