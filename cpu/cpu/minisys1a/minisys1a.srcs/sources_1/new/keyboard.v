`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: keyboard
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


module keyboard(
  input rst, // ��λ
  input clk, // ʱ��
  // ������������ȡ����clk��Ƶ�ʣ�����Ƶ�ʣ����ɿ��Ƕ�clk���б�Ƶ

  //�������������� ��������������Ӧ�������ź�
  input wire[`WordRange] addr,
  input wire en, // ʹ��
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // �������루����cpu��
  input wire we, //дʹ��

  //���͸��ٲ��� �������趼Ӧ�д����
  output reg[`WordRange] data_out,// �ڲ��˿ڼĴ��� �洢���µ�ֵ ���޼�������ȫf


  input[3:0] cols, // ���ߣ������ߣ�  ��������
  output reg[3:0] rows // ���ߣ�����ߣ� ��������

);

  // ״̬�����
  parameter COUNT = 20000; //��������  �������з�Ӧ������� ����20000��ʱ�����ں��ٿ����ߵĽ��

  parameter NO_KEY = 4'd0; // ��̬��û�м�����
  parameter MIGHT_HAVE_KEY = 4'd1; //�����м�λ���£���ʱӦ�õȴ�2000��ʱ�����ں�ʼɨ�����ߣ�ÿ��һ��ʱ�����ڣ������ͼ�1
  parameter SCAN_ROW0 = 4'd2; // ɨ����0
  parameter SCAN_ROW1 = 4'd3; // ɨ����1
  parameter SCAN_ROW2 = 4'd4; // ɨ����2
  parameter SCAN_ROW3 = 4'd5; // ɨ����3
  parameter YES_KEY = 4'd6; // �а�������
  
  // ״̬��
  reg[3:0] state;
  // ������
  reg[15:0] count;
  // �ڲ��Ĵ���
  reg[31:0] data;

  // ÿ�Ľ���һ��״̬ת��,״̬ת����state+1������ת����̬��ֱ����0
  always @(posedge clk) begin
    if (rst == `Enable) begin
      state <= NO_KEY;
      rows <= 4'b0000;
      count <= 16'd0;
      data <= 32'hffffffff;
    end else begin
      case (state)
        NO_KEY:begin
          rows <= 4'b0000; //����ȫ������͵�ƽ
          count <= 16'd0;
          if(cols != 4'b1111)begin  //��ʱ��������߲�ȫΪ1˵�������м�λ���� ״̬��ת
            state <= MIGHT_HAVE_KEY;
          end
        end 
        MIGHT_HAVE_KEY:begin
          if(count != COUNT)begin  //���� 
            count <= count + 16'd1;  
          end else if(cols == 4'b1111) begin  //�����ʱ������ȫΪ1 ˵�������� �ص���ʼ״̬
            state <= NO_KEY;
            count <= 16'd0;
          end else begin  //�����Ȼ��ȫΪ1 ˵������м�λ���� ��ʼɨ����
            rows <= 4'b1110;
            state <= SCAN_ROW0;
          end
        end
        SCAN_ROW0:begin
          if(cols == 4'b1111)begin //˵��������һ��
            rows <= 4'b1101;
            state <= SCAN_ROW1;
          end else begin //˵������һ��
            state <= NO_KEY;
            if(cols == 4'b1110)begin
              data <= 32'd13;
            end else if(cols == 4'b1101) begin
              data <= 32'd12;
            end else if(cols == 4'b1011) begin
              data <= 32'd11;
            end else if(cols == 4'b0111) begin
              data <= 32'd10;
            end
          end   
        end
        SCAN_ROW1:begin
          if(cols == 4'b1111)begin //˵��������һ��
            rows <= 4'b1011;
            state <= SCAN_ROW2;
          end else begin //˵������һ��
            state <= NO_KEY;
            if(cols == 4'b1110)begin
              data <= 32'd15;
            end else if(cols == 4'b1101) begin
              data <= 32'd9;
            end else if(cols == 4'b1011) begin
              data <= 32'd6;
            end else if(cols == 4'b0111) begin
              data <= 32'd3;
            end
          end           
        end
        SCAN_ROW2:begin
          if(cols == 4'b1111)begin //˵��������һ��
            rows <= 4'b0111;
            state <= SCAN_ROW3;
          end else begin //˵������һ��
            state <= NO_KEY;
            if(cols == 4'b1110)begin
              data <= 32'd0;
            end else if(cols == 4'b1101) begin
              data <= 32'd8;
            end else if(cols == 4'b1011) begin
              data <= 32'd5;
            end else if(cols == 4'b0111) begin
              data <= 32'd2;
            end
          end          
        end
        SCAN_ROW3:begin
          if(cols == 4'b1111)begin //˵��������һ��
            rows <= 4'b0000;
            state <= NO_KEY;
          end else begin //˵������һ��
            state <= NO_KEY;
            if(cols == 4'b1110)begin
              data <= 32'd14;
            end else if(cols == 4'b1101) begin
              data <= 32'd7;
            end else if(cols == 4'b1011) begin
              data <= 32'd4;
            end else if(cols == 4'b0111) begin
              data <= 32'd1;
            end
          end           
        end
        YES_KEY:begin
          if( {rows,cols} == 8'b11101110)begin
            data <= 32'd13;
          end else if( {rows,cols} == 8'b11101101)begin
            data <= 32'd12;
          end else if( {rows,cols} == 8'b11101011)begin
            data <= 32'd11;
          end else if( {rows,cols} == 8'b11100111)begin
            data <= 32'd10;
          end else if( {rows,cols} == 8'b11011110)begin
            data <= 32'd15;
          end else if( {rows,cols} == 8'b11011101)begin
            data <= 32'd9;
          end else if( {rows,cols} == 8'b11011011)begin
            data <= 32'd6;
          end else if( {rows,cols} == 8'b11010111)begin
            data <= 32'd3;
          end else if( {rows,cols} == 8'b10111110)begin
            data <= 32'd0;
          end else if( {rows,cols} == 8'b10111101)begin
            data <= 32'd8;
          end else if( {rows,cols} == 8'b10111011)begin
            data <= 32'd5;
          end else if( {rows,cols} == 8'b10110111)begin
            data <= 32'd2;
          end else if( {rows,cols} == 8'b01111110)begin
            data <= 32'd14;
          end else if( {rows,cols} == 8'b01111101)begin
            data <= 32'd7;
          end else if( {rows,cols} == 8'b01111011)begin
            data <= 32'd4;
          end else if( {rows,cols} == 8'b01110111)begin
            data <= 32'd1;
          end else begin
            data <= 32'hffffffff;
          end
          state <= NO_KEY;
        end
        default: begin
          state <= NO_KEY;
        end
      endcase
    end
  end

  always @(*)begin
    if(rst == `Enable) begin
      data_out <= `ZeroWord;
    end else if (addr == 32'hfffffc10 && en == `Enable && we ==`Disable) begin
      data_out <= data;
    end else begin
      data_out <= `ZeroWord;
    end
  end


endmodule
