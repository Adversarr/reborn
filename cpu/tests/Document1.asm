.data
buf0: 

	.word 1

.text

start:

	add $1, $2, $3

	lw $1, buf0($2)

