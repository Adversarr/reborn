.data
.text
___start:
	sw $0, 0xFD10($0)
	addiu 	$sp, $sp, 0 
	# call function main begin 
	sw 	$ra, 0($sp) 
	sw 	$s8, -4($sp) 
	ori 	$s8, $sp, 0 
	jal 	main 
	nop 
	lw 	$ra, 0($sp) 
	addiu 	$sp, $sp, 0 
	# call function main end 
	nop 
delay: 
	addiu 	$sp, $s8, -16 
	# time: 4($s8) 
	# i: -8($s8) 
	# pivot: -12($s8) 
entry.0: 
	lw 	$t2, 4($s8) 
	ori 	$t1, $zero, 0x4e2
	mult 	$t2, $t1 
	mflo 	$t1 
	sw 	$t1, -12($s8) 
	ori 	$t1, $zero, 0 
	sw 	$t1, -8($s8) 
while.cond.0: 
	lw 	$t2, -8($s8) 
	lw 	$t1, -12($s8) 
	slt 	$t1, $t2, $t1 
	bne 	$t1, $zero, while.body.0 
	nop 
	j 	while.end.0 
	nop 
while.body.0: 
	lw 	$t2, -8($s8) 
	ori 	$t1, $zero, 1 
	addu 	$t1, $t2, $t1 
	sw 	$t1, -8($s8) 
	j 	while.cond.0 
	nop 
while.end.0: 
	nop
ret.0: 
	ori 	$sp, $s8, 0 
	lw 	$ra, 0($s8) 
	lw 	$s8, -4($s8) 
	jr 	$ra 
	nop 
	nop 
main: 
	addiu 	$sp, $s8, -40 
	# .retval: -8($s8) 
	# i: -12($s8) 
	# left: -16($s8) 
	# right: -20($s8) 
	# l: -24($s8) 
	# r: -28($s8) 
	# offset: -32($s8) 
	# temp: -36($s8) 
	sw 	$zero, -8($s8) 
entry.1: 
	ori 	$t1, $zero, 0xfff 
	sw 	$t1, -16($s8) 
	lui 	$t1, 0xff 
	ori 	$t1, $t1, 0xf000 
	sw 	$t1, -20($s8) 
while.cond.1: 
	ori 	$t1, $zero, 1 
	bne 	$t1, $zero, while.body.1 
	nop 
	j 	while.end.1 
	nop 
while.body.1: 
	ori 	$t1, $zero, 0 
	sw 	$t1, -12($s8) 
while.cond.2: 
	lw 	$t2, -12($s8) 
	ori 	$t1, $zero, 24 
	slt 	$t1, $t2, $t1 
	bne 	$t1, $zero, while.body.2 
	nop 
	j 	while.end.2 
	nop 
while.body.2: 
	ori 	$t2, $zero, 12 
	lw 	$t1, -12($s8) 
	subu 	$t1, $t2, $t1 
	sw 	$t1, -32($s8) 
	lw 	$t2, -32($s8) 
	ori 	$t1, $zero, 0 
	slt 	$t1, $t2, $t1 
	bne 	$t1, $zero, if.then.0 
	nop 
	j 	if.end.0 
	nop 
if.then.0: 
	lw 	$t1, -32($s8) 
	subu 	$t1, $zero, $t1 
	sw 	$t1, -32($s8) 
	j 	if.end.0 
	nop 
if.end.0: 
	ori 	$t2, $zero, 12 
	lw 	$t1, -32($s8) 
	subu 	$t1, $t2, $t1 
	sw 	$t1, -32($s8) 
	lw 	$t2, -16($s8) 
	lw 	$t1, -32($s8) 
	srlv 	$t1, $t2, $t1 
	sw 	$t1, -24($s8) 
	lw 	$t2, -20($s8) 
	lw 	$t1, -32($s8) 
	sllv 	$t1, $t2, $t1 
	sw 	$t1, -28($s8) 
	lw 	$t2, -24($s8) 
	lw 	$t1, -28($s8) 
	xor 	$t1, $t2, $t1 
	sw 	$t1, -36($s8) 
	lw 	$t2, -36($s8) 
	ori 	$t1, $zero, 0 
	xor 	$t1, $t2, $t1 
	sw 	$t1, -36($s8) 
	addiu 	$t1, $zero, 0xfc60 
	lw 	$t3, -36($s8) 
	ori 	$t2, $zero, -1 
	and 	$t2, $t3, $t2 
	sw 	$t2, 0($t1) 
	addiu 	$t1, $zero, 0xfc64 
	lw 	$t3, -36($s8) 
	ori 	$t2, $zero, 16 
	srlv 	$t3, $t3, $t2 
	ori 	$t2, $zero, -1 
	and 	$t2, $t3, $t2 
	sw 	$t2, 0($t1) 
	ori 	$t1, $zero, 0x3e8 
	sw 	$t1, 0($sp) 
	addiu 	$sp, $sp, -4 
	# call function delay begin 
	sw 	$ra, 0($sp) 
	sw 	$s8, -4($sp) 
	ori 	$s8, $sp, 0 
	jal 	delay 
	nop 
	lw 	$ra, 0($sp) 
	addiu 	$sp, $sp, 4 
	# call function delay end 
	lw 	$t2, -12($s8) 
	ori 	$t1, $zero, 1 
	addu 	$t1, $t2, $t1 
	sw 	$t1, -12($s8) 
	j 	while.cond.2 
	nop 
while.end.2: 
	j 	while.cond.1 
	nop 
while.end.1: 
	ori 	$t1, $zero, 0 
	sw 	$t1, -8($s8) 
	j 	ret.1 
	nop 
ret.1: 
	lw 	$t1, -8($s8) 
	ori 	$v0, $t1, 0 
	ori 	$sp, $s8, 0 
	lw 	$ra, 0($s8) 
	lw 	$s8, -4($s8) 
	jr 	$ra 
	nop 
	nop 