`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: pwm
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


module pwm(
  input rst, // ���ã�ȫ�����
  input clk, // ʱ��

  //�������������� ��������������Ӧ�������ź�
  input wire[`WordRange] addr,
  input wire en, // ʹ��
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // �������루����cpu��
  input wire we, //дʹ��

  //���͸��ٲ��� �������趼Ӧ�д����
  output wire[`WordRange] data_out,

  output reg result // PWM���ƽ��
);

  reg[15:0] threshold; // ���ֵ�Ĵ���
  reg[15:0] compare; // �Ա�ֵ�Ĵ���
  reg[7:0] ctrl; // ���ƼĴ���
  reg[15:0] current; // ��ǰֵ
  assign data_out = addr[3:2] == 2'b00 ? {compare, threshold} : 
                    addr[3:2] == 2'b01 ? {24'h0000_00, ctrl} : `ZeroWord;

  always @(posedge clk) begin //д��������д
    if(addr[31:4] == {28'hfffffc3} && en == `Enable && we == `Enable)begin
      if(addr[3:2] == 2'b00) begin
        if(byte_sel[0] == 1'b1)begin
          threshold[7:0] <= data_in[7:0];
        end
        if(byte_sel[1] == 1'b1)begin
          threshold[15:8] <= data_in[15:8];
        end
        if(byte_sel[2] == 1'b1) begin
          compare[7:0] <= data_in[23:16];
        end
        if(byte_sel[3] == 1'b1) begin
          compare[15:8] <= data_in[31:24];
        end
      end else if(addr[3:2] == 2'b01) begin
        if(byte_sel[0] == 1'b1) begin
          ctrl <= data_in[7:0];
        end
      end
    end
  end

  always @(posedge clk) begin
    // ����
    if (rst == `Enable) begin
      threshold <= 16'hffff;
      compare <= 16'h7fff;
      ctrl <= 8'd1;
      current <= 16'd0;
      result <= `Enable;
    end else begin
      if (current == threshold) begin
        current <= 16'd0;
        result <= `Enable;
      end
        // һ������¼�һ����
        current = current + 16'd1;
    end
      // ֻ����ʹ�ܣ��ҿ��ƼĴ���[0]λ��Чʱ���ű�֤����ɿ�
    if ( ctrl[0] ) begin
      if (current > compare) begin
        result <= `Disable;
      end else begin
        result <= `Enable;
      end
    end
  end



endmodule
