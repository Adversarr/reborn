
# Minisys汇编程序设计3
# 以原码一位乘为基础，设计一个两个数乘法程序：
# - 不断从拨码开关中读入数据，其中SW3-SW0为乘数，SW15~SW12为被乘数
# - 乘法结果输出到GLD7~GLD0
# - 要求程序中必须出现SRL,SLL指令。
# tested

# LED: 0xFFFFFC60 - 0xFFFFFC62 (3 byte, 24bit)
# DIP switch:  0xFFFFFC70 - 0xFFFFFC72 (3 byte)
# GLD7~GLD0: LED[7:0]

.DATA
.TEXT   0x0000
start:
    # load
    lw      $t0, 0xFC70 ($0) 
    andi    $s1, $t0, 0x000F
    srl     $s2, $t0, 12
    andi    $s2, $s2, 0x000F

    # addi    $s1, $0, 5
    # addi    $s2, $0, 4

    addi    $s0, $0, 0
    andi    $t2, $s1, 1
    beq     $t2, $0, skip1
    add     $s0, $s0, $s2
skip1:
    srl     $s1, $s1, 1
    andi    $t2, $s1, 1
    beq     $t2, $0, skip2
    sll     $s2, $s2, 1
    add     $s0, $s0, $s2
skip2:
    srl     $s1, $s1, 1
    andi    $t2, $s1, 1
    beq     $t2, $0, skip3
    sll     $s2, $s2, 1
    add     $s0, $s0, $s2
skip3:    
    srl     $s1, $s1, 1
    andi    $t2, $s1, 1
    beq     $t2, $0, skip4
    sll     $s2, $s2, 1
    add     $s0, $s0, $s2
skip4:
    # write
    andi    $s0, $s0, 0x00FF
    sw      $s0, 0xFC60 ($0) 

    j       start