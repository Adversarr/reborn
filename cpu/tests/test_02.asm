.DATA
.TEXT
start:
test_sign_extend:
	addi 	$t1, $0, 0xfdca
	addiu 	$t1, $0, 0xfdca
	lw 		$t1, 0xfdca ($0)
	sw 		$t1, 0xfdca ($0)
	nop
	nop
	nop

test_zero_extend:
	andi 	$t1, $0, 0xfdca
	ori 	$t1, $0, 0xfdca
	xori 	$t1, $0, 0xfdca
	nop
	nop
	nop


