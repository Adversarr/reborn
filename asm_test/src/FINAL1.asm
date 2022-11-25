.DATA 0X0
    BUF0:   .word 0x55
    BUF1:   .word 0xAA

.TEXT 0X0000
start:
    lw      $v0,BUF0($zero)
    lw      $v1,BUF1($zero)
    add     $at,$v0,$v1
    sw      $at,8($zero)
    subu    $a0,$v1,$v0
    slt     $a0,$v0,$at
    and     $at,$v1,$a3
    or      $a2,$v0,$at
    xor     $a3,$v0,$v1
    nor     $a2,$a1,$at
lop:
    beq     $v1,$v0,lop
lop1:
    sub     $v0,$v0,$a1
    bne     $a1,$v0,lop1
    beq     $at,$at,lop2
    nop
lop2:
    jal subp
    j   next
subp:
    jr  $ra
next:
    addi    $v0,$zero,0x99
    ori     $v1,$zero,0x77
    sll     $v1,$v0,4
    srl     $v1,$v0,4
    srlv    $v1,$v0,$at
    lui     $a2,0x9988
    sra     $a3,$a2,4
    addi    $v0,$zero,0
    addi    $v1,$zero,2
    sub     $at,$v0,$v1
    lui     $a0,0xFFFF
    ori     $a0,$a0,0xF000
    lw      $v0,0xC70($a0)
    sw      $v0,0xC60($a0)
    j       start