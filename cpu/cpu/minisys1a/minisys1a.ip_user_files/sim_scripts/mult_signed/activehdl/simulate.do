onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+mult_signed -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.mult_signed xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {mult_signed.udo}

run -all

endsim

quit -force
