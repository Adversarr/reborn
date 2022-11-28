onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib signed_mult_5stage_opt

do {wave.do}

view wave
view structure
view signals

do {signed_mult_5stage.udo}

run -all

quit -force
