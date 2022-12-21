onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib uart_bmpg_1_opt

do {wave.do}

view wave
view structure
view signals

do {uart_bmpg_1.udo}

run -all

quit -force
