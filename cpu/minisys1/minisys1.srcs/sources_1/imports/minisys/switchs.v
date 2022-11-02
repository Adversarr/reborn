`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switchs(switclk,switrst,switchread,switchaddrcs,
    switchaddr, switchrdata,switch_i);
    input switclk,switrst;
    input switchaddrcs,switchread;
    input [1:0] switchaddr;
    output [15:0] switchrdata;
    //²¦Âë¿ª¹ØÊäÈë
    input [23:0] switch_i;

    reg [15:0] switchrdata;
    always@(negedge switclk or posedge switrst) begin
      if (switrst)
        switchrdata = 0;
      else if (switchaddrcs && switchread) begin
        switchrdata = switchaddr[1] ? {8'b00000000, switch_i[23:16]}
                                    : switch_i[15:0];
      end else begin
        switchrdata = 0;
      end
    end
endmodule
