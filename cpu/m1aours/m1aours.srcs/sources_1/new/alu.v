`include "public.v"

// ALU: except for mul and div
module alu (
  input[`WordRange] data1,
  input[`WordRange] data2,
  input[`ALUOpRange] op,
  output[`WordRange] res,
  output wire zf, // zero-flag: result == 0 => 1
  output wire cf, // carry-flag: carry => 1
  output wire sf, // sign-flag: neg => 1
  output wire of // overflow-flag: signed, overflow => 1

);
  // result[32] => overflow result
  reg [32:0] result;

  // data, signed.
  wire signed [31:0] s_data1;
  wire signed [31:0] s_data2;
  assign s_data1 = data1;
  assign s_data2 = data2;

  // result output
  assign res = result[`WordRange];

  always @(*) begin
    case (op)
      `ALUOP_NOP: begin // �޲���
        result <= `ZeroWord;
      end
      `ALUOP_ADDU: begin // �޷��ż�
        result <= data1 + data2;
      end
      `ALUOP_ADD: begin // �з��ż�
        result <= s_data1 + s_data2;
      end
      `ALUOP_SUBU: begin // �޷��ż�
        result <= data1 - data2;
      end
      `ALUOP_SUB: begin // �з��ż�
        result <= s_data1 - s_data2;
      end
      `ALUOP_AND: begin // ��λ��
        result <= data1 & data2;
      end
      `ALUOP_OR: begin // ��λ��
        result <= data1 | data2;
      end
      `ALUOP_XOR: begin // ��λ���
        result <= data1 ^ data2;
      end
      `ALUOP_NOR: begin // ��λ���
        result <= ~(data1 | data2);
      end
      `ALUOP_SLL: begin // �߼�����
        result <= data2 << data1[4:0]; // ע��data1�����ƶ���λ��
      end
      `ALUOP_SRL: begin // �߼�����
        result <= data2 >> data1[4:0];
      end
      `ALUOP_SRA: begin // ��������
        // https://blog.csdn.net/qq_41634276/article/details/80414488
        result <= s_data2 >>> s_data1[4:0];
      end
      `ALUOP_SLT: begin // less-than���з��ţ�
        result <= s_data1 < s_data2 ? 33'd1 : 33'd0;
      end
      `ALUOP_SLTU: begin // less-than���޷��ţ�
        result <= data1 < data2 ? 33'd1 : 33'd0;  
      end
    endcase
  end

  /// Setup flags
  assign cf = result[32];
  assign zf = result[31:0] == 32'd0 ? 1'b1 : 1'b0;
  assign sf = result[31];
  assign of = result[32];

endmodule
