//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  inst_rom
// File:    inst_rom.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: Ö¸Áî´æ´¢Æ÷
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_rom(
	input	wire										clk,
	input wire[`InstAddrBus]			addr,
	output wire[`InstBus]					inst,
  // uart part
  input wire                    upg_rst_i,
  input wire                    upg_clk_i,
  input wire                    upg_wen_i,
  input wire [14:0]             upg_addr_i,
  input wire [`InstBus]         upg_data_i,
  input wire                    upg_done_i
);
  // kick off
  wire cpu_en = upg_rst_i | (~upg_rst_i & upg_done_i);

  blk_mem_gen_0 imem_inst(
    .addra(cpu_en ? addr[15:2] : upg_addr_i[13:0]),
    .clka(cpu_en ? clk : upg_clk_i),
    .dina(cpu_en ? 32'h0000_0000 : upg_data_i),
    .douta(inst),
    .wea(cpu_en ? 1'b0 : upg_wen_i & !upg_addr_i[14])
  );

endmodule