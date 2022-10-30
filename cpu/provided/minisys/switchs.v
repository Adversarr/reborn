`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module switchs(switclk,switrst,switchread,switchaddrcs,switchrdata,switch_i);
    input switclk,switrst;
    input switchaddrcs,switchread;
    output [15:0] switchrdata;
    //²¦Âë¿ª¹ØÊäÈë
    input [15:0] switch_i;

    reg [15:0] switchrdata;
    always@(negedge switclk or posedge switrst) begin
 
    end
endmodule
