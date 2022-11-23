set_property SRC_FILE_INFO {cfile:d:/Repo/reborn/cpu/m1aours/m1aours.srcs/sources_1/ip/cpu_clk/cpu_clk.xdc rfile:../../../m1aours.srcs/sources_1/ip/cpu_clk/cpu_clk.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
