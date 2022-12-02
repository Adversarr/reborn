onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.div_signed xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {div_signed.udo}

run -all

quit -force
