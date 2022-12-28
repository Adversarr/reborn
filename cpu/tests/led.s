.DATA
.TEXT
__start:
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
main: 
	addiu 	$sp, $s8, -16 
	# .retval: -8($s8) 
	# i: -12($s8) 
	sw 	$zero, -8($s8) 
entry.0: 
	nop
while.cond.0: 
	ori 	$t1, $zero, 1 
	bne 	$t1, $zero, while.body.0 
	nop 
	j 	while.end.0 
	nop 
while.body.0: 
	addiu 	$t1, $zero, 0xfd10 
	lw 	$t3, -12($s8) 
	ori 	$t2, $zero, 10 
	srlv 	$t2, $t3, $t2 
	sw 	$t2, 0($t1) 
	lw 	$t2, -12($s8) 
	ori 	$t1, $zero, 1 
	addu 	$t1, $t2, $t1 
	sw 	$t1, -12($s8) 
	j 	while.cond.0 
	nop 
while.end.0: 
	ori 	$t1, $zero, 0 
	sw 	$t1, -8($s8) 
	j 	ret.0 
	nop 
ret.0: 
	lw 	$t1, -8($s8) 
	ori 	$v0, $t1, 0 
	ori 	$sp, $s8, 0 
	lw 	$ra, 0($s8) 
	lw 	$s8, -4($s8) 
	jr 	$ra 
	nop 
	nop 