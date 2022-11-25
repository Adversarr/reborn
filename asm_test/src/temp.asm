.DATA
.TEXT   0x0000
start:
	addi  $t0, $0, 123
	addi  $t0, $t0, -1
	addi  $t0, $t0, -1
	addi  $t0, $t0, -1
	addiu  $t0, $0, 456
	addiu  $t0, $t0, -1
	addiu  $t0, $t0, -1
	addiu  $t0, $t0, -1
    j       start
