
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
    lui     $t0, 0x02FA
    ori     $t0, $0, 0xF080
loop_sleep:
    addi    $t0, $t0, -1
    bne     $t0, loop_sleep

    # input from DIP switch
    # $s1 <- SW[23:0]
    lw      $s1, 0xFC70 ($0)
    # $t0 <- SW[23:21]
    srl     $t0, $s1, 21
    andi    $t0, $t0, 0x0007

    sltiu   $t1, $t0, 0
    beq     $t1, case0
    sltiu   $t1, $t0, 1
    beq     $t1, case1
    sltiu   $t1, $t0, 2
    beq     $t1, case2
    sltiu   $t1, $t0, 3
    beq     $t1, case3
    sltiu   $t1, $t0, 4
    beq     $t1, case4
    sltiu   $t1, $t0, 5
    beq     $t1, case5
    sltiu   $t1, $t0, 6
    beq     $t1, case6
    sltiu   $t1, $t0, 7
    beq     $t1, case7

case 0:
case 4:
    j       action
case 1:
    addi    $s0, $s1, 0
    j       action
case 2:
    addi    $s0, $s0, 1
    j       action
case 3:
    addi    $s0, $s0, -1
    j       action
case 5:
    sll     $s0, $s0, 1
    j       action
case 6:
    srl     $s0, $s0, 1
    j       action
case 7:
    andi    $t0, $s0, 0x8000
    srl     $s0, $s0, 1
    or      $s0, $s0, $t0
    j       action
    
    j       start