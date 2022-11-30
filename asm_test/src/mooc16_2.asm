
# Minisys汇编程序设计2
# 按如下要求设计一个有24个发光二极管的彩灯程序
# - 能够循环执行
# - 每隔大约半秒变换一次（用循环来获得大约半秒延迟）
# - 每次灯的变换如下，1表示亮，0表示灭
# - 灯从两边向中间依次点亮，再从中间向两边依次熄灭。

# 指令间隔: 10ns, 
# 0.5s / 10ns = 0x02FAF080
# 考虑 每个循环执行2个指令, 则再折半为 0x017D7840
# 取 0x00155CC0差不多可以满足0.5s变化一次
# 独特的 minisys1A I/O编址方式: 
# 0xFC70 -> LED[15:0], 0xFC74 -> LED[23:16]
# 0xFC60 <- DIP[15:0], 0xFC64 <- DIP[23:16]
# tested


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