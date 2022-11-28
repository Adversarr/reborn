onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib unsigned_mul_5stage_opt

do {wave.do}

view wave
view structure
view signals

do {unsigned_mul_5stage.udo}

run -all

quit -force
