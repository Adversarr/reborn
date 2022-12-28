`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: datamem
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


module dmem(
  //cpu
  input wire clk,
  input wire enable,
  input wire we,
  input wire[`WordRange] addr,
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in,
  output wire[`WordRange] data_out,
  
  //uart
  input wire upg_rst,
  input wire upg_clk,
  input wire upg_wen,
  input wire[13:0] upg_adr,
  input wire[31:0] upg_dat,
  input wire upg_done);
  wire kickOff = upg_rst | (~upg_rst & upg_done);
  
  wire ram_enable;
  wire weA,weB,weC,weD;
  // 地址高16位全0且enable有效 才真正有效
  assign ram_enable = (~|addr[31:16]) & enable;  
  
  assign weA = byte_sel[0] & we;
  assign weB = byte_sel[1] & we;
  assign weC = byte_sel[2] & we;
  assign weD = byte_sel[3] & we;
  
  
  dmem8 ramA(
      .addra         (kickOff ?   addr[15:2]      :   upg_adr),
      .clka          (kickOff ?   clk             :   upg_clk),
      .dina          (kickOff ?   data_in[7:0]    :   upg_dat[7:0]),
      .douta         (data_out[7:0]),
//      .ena           (kickOff ?   ram_enable       :   1'b1),
      .wea           (kickOff ?   weA             :   upg_wen)
  );  //最低位字节(00)
  dmem8 ramB(
      .addra         (kickOff ?   addr[15:2]      :   upg_adr),
      .clka          (kickOff ?   clk             :   upg_clk),
      .dina          (kickOff ?   data_in[15:8]   :   upg_dat[15:8]),
      .douta         (data_out[15:8]),
//      .ena           (kickOff ?   ram_enable       :   1'b1),
      .wea           (kickOff ?   weA             :   upg_wen)
  );//(01)
  dmem8 ramC(
      .addra         (kickOff ?   addr[15:2]      :   upg_adr),
      .clka          (kickOff ?   clk             :   upg_clk),
      .dina          (kickOff ?   data_in[23:16]  :   upg_dat[23:16]),
      .douta         (data_out[23:16]),
//      .ena           (kickOff ?   ram_enable       :   1'b1),
      .wea           (kickOff ?   weA             :   upg_wen)
  );//(10)
  dmem8 ramD(
      .addra         (kickOff ?   addr[15:2]      :   upg_adr),
      .clka          (kickOff ?   clk             :   upg_clk),
      .dina          (kickOff ?   data_in[31:24]  :   upg_dat[31:24]),
      .douta         (data_out[31:24]),
//      .ena           (kickOff ?   ram_enable       :   1'b1),
      .wea           (kickOff ?   weA             :   upg_wen)
  );  //最高位字节(11)
endmodule
