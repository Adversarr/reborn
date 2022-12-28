.DATA
.TEXT   0x0000
start:
    addi    $s1, $0, 0
loop0:
    lui     $s0, 0x0015
    ori     $s0, $s0, 0x5CC0
    # addi     $s0, $0, 0x0020
loop_sleep0:
    addi    $s0, $s0, -1
    bne     $s0, $0, loop_sleep0

    addi    $s2, $0, 0x0FFF
    sll     $s3, $s2, 12
    addi    $t1, $0, 12
    subu    $t1, $t1, $s1
    srlv    $s4, $s2, $t1   
    sllv    $s5, $s3, $t1
    xor     $s6, $s4, $s5
    xor     $s6, $s6, $0

    # LED
    sw      $s6, 0xFC60 ($0) 
    srl     $t0, $s6, 16
    sw      $t0, 0xFC64 ($0) 

    addi    $s1, $s1, 1
    addi    $t0, $0, 12
    bne     $s1, $t0, loop0

    addi    $s1, $0, 0
loop1:
    lui     $s0, 0x0015
    ori     $s0, $s0, 0x5CC0
    # addi     $s0, $0, 0x0020
loop_sleep1:
    addi    $s0, $s0, -1
    bne     $s0, $0, loop_sleep1

    addi    $s2, $0, 0x0FFF
    sll     $s3, $s2, 12
    srlv    $s4, $s2, $s1   
    sllv    $s5, $s3, $s1
    or      $s6, $s4, $s5

    # LED
    sw      $s6, 0xFC60 ($0) 
    srl     $t0, $s6, 16
    sw      $t0, 0xFC64 ($0) 

    addi    $s1, $s1, 1
    addi    $t0, $0, 12
    bne     $s1, $t0, loop1
    
    j       start