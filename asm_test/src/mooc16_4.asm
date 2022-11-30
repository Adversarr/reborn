
# Minisys汇编程序设计4
# 程序内部有一16位变量VAL，YLD[7:0] ~ GLD[7:0]始终输出VAL的值。
# SW23/SW22/SW21为功能选择，含义如下表：
# SW23    SW22    SW21    动作 
# X       0       0       无动作 
# 0       0       1       将SW15~SW0这16位作为输入赋值给VAL 
# 0       1       0       VAL=VAL+1 （每隔约1秒动作一次） 
# 0       1       1       VAL=VAL-1（每隔约1秒动作一次） 
# 1       0       1       VAL左移1位（每隔约1秒动作一次） 
# 1       1       0       VAL逻辑右移1位（每隔约1秒动作一次） 
# 1       1       1       VAL算术右移1位（每隔约1秒动作一次）   


# LED: 0xFFFFFC60 - 0xFFFFFC62 (3 byte, 24bit)
# DIP switch:  0xFFFFFC70 - 0xFFFFFC72 (3 byte)
# 指令间隔: 10ns, 0.5s => 循环周期 0x02FAF080


.DATA
.TEXT   0x0000
start:
    addi    $s0, $0, 0
action:
    andi    $s0, $s0, 0xFFFF

    # output to LED
    # LED[23:0] <- $s0[23:0]
    sw      $s0, 0xFC60 ($0)

    # sleep for 1 sec
    lui     $t0, 0x0090
    ori     $t0, $t0, 0x5CC0
loop_sleep:
    addi    $t0, $t0, -1
    bne     $t0, $0, loop_sleep

    # input from DIP switch
    # $s1 <- SW[15:0]
    lw      $s1, 0xFC70 ($0)
    # $t0 <- SW[23:21]
    lw      $t0, 0xFC74 ($0)
    srl     $t0, $t0, 5
    andi    $t0, $t0, 0x0007

    addi    $t1, $0, 0
    beq     $t0, $t1, case04
    addi    $t1, $0, 1
    beq     $t0, $t1, case1
    addi    $t1, $0, 2
    beq     $t0, $t1, case2
    addi    $t1, $0, 3
    beq     $t0, $t1, case3
    addi    $t1, $0, 4
    beq     $t0, $t1, case04
    addi    $t1, $0, 5
    beq     $t0, $t1, case5
    addi    $t1, $0, 6
    beq     $t0, $t1, case6
    addi    $t1, $0, 7
    beq     $t0, $t1, case7

case04:
    j       action
case1:
    addi    $s0, $s1, 0
    j       action
case2:
    addi    $s0, $s0, 1
    j       action
case3:
    addi    $s0, $s0, -1
    j       action
case5:
    sll     $s0, $s0, 1
    j       action
case6:
    srl     $s0, $s0, 1
    j       action
case7:
    andi    $t0, $s0, 0x8000
    srl     $s0, $s0, 1
    or      $s0, $s0, $t0
    j       action
    
    j       start