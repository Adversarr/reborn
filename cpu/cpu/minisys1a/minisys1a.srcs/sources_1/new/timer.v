`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/02 10:02:20
// Design Name: 
// Module Name: timer
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

module timer(
  input rst, // ��λ
  input clk, // ʱ��
  
  //�������������� ��������������Ӧ�������ź�
  input wire[`WordRange] addr,
  input wire en, // ʹ��
  input wire[3:0] byte_sel,
  input wire[`WordRange] data_in, // �������루����cpu��
  input wire we, //дʹ��
  
  // TODO: Replace interface.
  input cs, // Ƭѡ
  input rd, // ��ģʽ
  input wr, // дģʽ
  input [2:0] port, // �ڲ��Ĵ����˿�ѡ�񣬷�ʽ�Ĵ�����0/2����ʼֵ�Ĵ�����4/
  input [15:0] data, // ��������
  
  output reg[15:0] out1, // CNT1���
  output reg[15:0] out2, // CNT2���
  
  output reg cout1, // COUT1���͵�ƽ��Ч
  output reg cout2 // COUT2���͵�ƽ��Ч

  );
  
  // ��ʽ�Ĵ���
  reg[15:0] config1;
  reg[15:0] config2;
  // ״̬�Ĵ���
  reg[15:0] status1;
  reg[15:0] status2;
  // ��ʼֵ�Ĵ���
  reg[15:0] init1;
  reg[15:0] init2;
  // ��ǰֵ�Ĵ���
  reg[15:0] current1;
  reg[15:0] current2;

  // �����߼��Լ����ڲ��Ĵ����ķ���
  always @(posedge clk) begin
    if (rst == `Enable) begin
      config1 <= 16'd0;   config2 <= 16'd0;
      status1 <= 16'd0;   status2 <= 16'd0;
      init1 <= 16'd0;     init2 <= 16'd0;
      current1 <= 16'd0;  current2 <= 16'd0;
      out1 <= 16'd0;      out2 <= 16'd0;
      cout1 <= `Enable;   cout2 <= `Enable;
    end else begin
      if (cs == `Enable) begin
        if (wr == `Enable) begin
          // �����ֻд�Ĵ����ķ���
          if (port == 3'h0) begin
            config1 <= data;
            // ��ʽ�Ĵ������ú�û��д������ʼֵʱ��״̬�Ĵ�����Чλ��0
            status1 <= status1 & 16'h7FFF;
          end
          if (port == 3'h2) begin
            config2 <= data;
            status2 <= status2 & 16'h7FFF;
          end
          if (port == 3'h4) begin
            init1 <= data;
            // д�ü�����ʼֵ��״̬�Ĵ�����Чλ��1
            status1 <= status1 | 16'h8000;
          end
          if (port == 3'h6) begin
            init2 <= data;
            status2 <= status2 | 16'h8000;
          end
        end else if (rd == `Enable) begin
          // �����ֻ���Ĵ����ķ���
          if (port == 3'h0) begin
            out1 <= status1;
          end
          if (port == 3'h2) begin
            out2 <= status2;
          end
          if (port == 3'h4) begin
            out1 <= current1;
          end
          if (port == 3'h6) begin
            out1 <= current2;
          end
        end
      end
    end
  end

  // ����ʱ�Ӷ�CNT1���в���
  always @(posedge clk) begin
    current1 <= current1 - 16'd1;
    // ����߽��߼�
    if (config1[0] == `Disable) begin
      // ��ʱģʽ  
      if (current1 == 16'd1) begin
        // ����״̬�Ĵ�����ЧλΪ0����ʱ��λΪ1
        status1 <= status1 & 16'h7FFF | 16'h0001;
        cout1 <= `Disable;
      end
    end else begin
      // ����ģʽ
      if (current1 == 16'd0) begin
        // ����״̬�Ĵ�����ЧλΪ0��������λΪ1
        status1 <= status1 & 16'h7FFF | 16'h0002;
        cout1 <= `Disable;
      end
    end
  end

  // ����ʱ�Ӷ�CNT2���в���
  always @(posedge clk) begin
    current2 <= current2 - 16'd1;
    // ����߽��߼�
    if (config2[0] == `Disable) begin
      // ��ʱģʽ  
      if (current2 == 16'd1) begin
        // ����״̬�Ĵ�����ЧλΪ0����ʱ��λΪ1
        status2 <= status2 & 16'h7FFF | 16'h0001;
        cout1 <= `Disable;
      end
    end else begin
      // ����ģʽ
      if (current2 == 16'd0) begin
        // ����״̬�Ĵ�����ЧλΪ0��������λΪ1
        status2 <= status2 & 16'h7FFF | 16'h0002;
        cout1 <= `Disable;
      end
    end
  end

  // ��һ���������������ظ��߼�
  always @(cout1) begin
    if (cout1 == `Disable) begin
      if (config1[1] == `Enable) begin // �ظ�ģʽ
        current1 <= init1;
        cout1 <= `Enable;
      end else begin // ���ظ�ģʽ
        // TODO
      end
    end
  end

  always @(cout2) begin
    if (cout2 == `Disable) begin
      if (config2[1] == `Enable) begin // �ظ�ģʽ
        current2 <= init2;
        cout2 <= `Enable;
      end else begin // ���ظ�ģʽ
        // TODO
      end
    end
  end

endmodule
