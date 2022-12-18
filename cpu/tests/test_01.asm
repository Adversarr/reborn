.DATA
.TEXT
start:
test_add:
    addi    $t0, $0, -6
    addi    $t1, $0, -5
    addi    $t2, $0, 4
    nop
    add     $t3, $t0, $t1   # $t3 = -11
    add     $t4, $t0, $t1   # $t4 = -11
    addu    $t5, $t2, $t1   # $t5 = -1
    addu    $t6, $t2, $t1   # $t6 = -1
    nop
    nop
    nop

test_bitwise:
    addi    $t0, $0, 3
    addi    $t1, $0, 6
    addi    $t2, $0, -5
    nop
    and     $t3, $t0, $t1   # $t3 = 2 (b'0010)
    or      $t4, $t0, $t1   # $t4 = 7 (b'0111)
    xor     $t5, $t0, $t1   # $t5 = 5 (b'0101)
    nor     $t6, $t0, $t1   # $t6 = -8 (b'1111...1000)
    nop
    slt     $t7, $t0, $t1   # $t7 = 1
    slt     $s0, $t1, $t2   # $s0 = 0
    sltu    $s1, $t0, $t1   # $s1 = 1
    sltu    $s2, $t1, $t2   # $s2 = 1
    nop
    nop
    nop

test_shift:
    addi    $t0, $0, 2
    addi    $t1, $0, 5
    addi    $t2, $0, -6
    nop
    sll     $t3, $t1, 2     # $t3 = 0x14 (b'0001_0100)
    srl     $t4, $t1, 2     # $t4 = 1    (b'0000_0001)
    srl     $t5, $t2, 2     # $t5 = 3fff_fffe
    sra     $t6, $t1, 2     # $t6 = 1    (b'0000...0001)
    sra     $t7, $t2, 2     # $t7 = -2   (b'1111...1110)
    nop
    sllv    $s0, $t1, $t0   # $s0 = 0x14 (b'0001_0100)
    srlv    $s1, $t1, $t0   # $s1 = 1    (b'0000_0001)
    srlv    $s2, $t2, $t0   # $s2 = 1    (b'0000_0001)
    srav    $s3, $t1, $t0   # $s3 = 1    (b'0000...0001)
    srav    $s4, $t2, $t0   # $s4 = -2   (b'1111...1110)
    nop
    nop
    nop

test_j:
    j       test_add_i
    nop
    nop
    nop

test_failed:
    addi $t0, $0, 0x2468
    j test_failed   # failed
    nop
    nop
    nop

test_success:
    addi    $t0, $0, 0x1357
    j       test_success  # complete
    nop
    nop
    nop

test_add_i:
    addi    $t0, $0, -6
    addi    $t1, $0, 5
    addi    $t2, $0, 4
    nop
    addi    $t3, $t0, 5         # $t3 = -1, overflow exception
    addiu   $t4, $t0, 5         # $t4 = -1
    addi    $t3, $t0, 0x8000    # $t3 = -ffff7fffa, overflow exception
    addiu   $t4, $t0, 0x8000    # $t4 = -ffff7ffa
    nop
    nop
    nop

test_bitwise_i:
    addi    $t0, $0, 3
    addi    $t1, $0, 6
    addi    $t2, $0, 5
    nop
    addi    $t3, $t0, 6     # $t3 = 9 (b'0010)
    ori     $t4, $t0, 6     # $t4 = 7 (b'0111)
    xori    $t5, $t0, 6     # $t5 = 5 (b'0101)
    nop
    nop
    nop

test_lui:
    addi    $t0, $0, 0x1234
    nop
    lui     $t0, 0x1234     # t0 = 0x12340000
    nop
    nop
    nop

test_lw:
    addi    $t0, $0, 1234
    nop
    sw      $t0, 0xFC50 ($0)    # load DIP_switch
    addi    $t0, $0, 0
    lw      $t0, 0xFC60 ($0)    # save LED
    addi    $t0, $0, 4567
    lw      $t0, 0x1234 ($0)    # load
    addi    $t0, $0, 0
    sw      $t0, 0x1234 ($0)    # save, $t0 = 0x4567
    nop
    nop
    nop

test_beq:
    addi    $t0, $0, 1
    addi    $t1, $0, 1
    addi    $t2, $0, 2
    nop
    beq     $t0, $t2, test_failed   # ignore
    beq     $t0, $t1, test_bne      # goto test_bne
    j       test_failed
    nop
    nop
    nop

test_bne:
    bne     $t0, $t1, test_failed   # ignore
    bne     $t0, $t2, test_slti     # goto test_slti
    j       test_failed
    nop
    nop
    nop

test_slti:
    addi    $t0, $0, 2
    addi    $t1, $0, 2
    addi    $t2, $0, -2
    nop
    slti    $s1, $t1, 3         # $s1 = 1
    slti    $s1, $t2, -3        # $s1 = 0
    sltiu   $s1, $t0, 1         # $s1 = 0
    sltiu   $s1, $t0, -3        # $s1 = 1
    nop
    nop
    nop

test_jal:
    addi    $s0, $0, 0
    jal     test_jr
    addi    $t0, $0, 0xf1a9
    bne     $t0, $s0, test_failed   # ignore
    j       test_success
    nop
    nop
    nop

test_jr:
    addi    $s0, $0, 0xf1a9
    jr      $ra
    j       test_failed