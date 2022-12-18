vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv "+incdir+../../../../minisys1a.srcs/sources_1/ip/cuclock" "+incdir+../../../../minisys1a.srcs/sources_1/ip/cuclock" \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../minisys1a.srcs/sources_1/ip/cuclock" "+incdir+../../../../minisys1a.srcs/sources_1/ip/cuclock" \
"../../../../minisys1a.srcs/sources_1/ip/cuclock/cuclock_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"
