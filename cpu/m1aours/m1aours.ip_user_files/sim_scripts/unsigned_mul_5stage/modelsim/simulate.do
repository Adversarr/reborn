onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L xbip_utils_v3_0_8 -L xbip_pipe_v3_0_4 -L xbip_bram18k_v3_0_4 -L mult_gen_v12_0_13 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.unsigned_mul_5stage xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {unsigned_mul_5stage.udo}

run -all

quit -force
