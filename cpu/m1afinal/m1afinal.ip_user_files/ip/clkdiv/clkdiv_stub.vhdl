-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
-- Date        : Mon Dec 19 10:43:22 2022
-- Host        : DESKTOP-GH9H0GG running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               C:/Users/JerryYang/Repo/reborn/cpu/m1afinal/m1afinal.srcs/sources_1/ip/clkdiv/clkdiv_stub.vhdl
-- Design      : clkdiv
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a12ticsg325-1L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clkdiv is
  Port ( 
    cpuclk : out STD_LOGIC;
    uartclk : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clkdiv;

architecture stub of clkdiv is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "cpuclk,uartclk,clk_in1";
begin
end;
