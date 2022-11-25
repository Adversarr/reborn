.DATA

# Minisys汇编程序设计2
# 按如下要求设计一个有24个发光二极管的彩灯程序
# - 能够循环执行
# - 每隔大约半秒变换一次（用循环来获得大约半秒延迟）
# - 每次灯的变换如下，1表示亮，0表示灭
# - 灯从两边向中间依次点亮，再从中间向两边依次熄灭。

# 指令间隔: 10ns, 0.5s => 循环周期 0x02FAF080
# LED: 0xFFFFFC60 - 0xFFFFFC62 (3 byte, 24bit)
# 小端地址: 0xFC63 | 0xFC62 | 0xFC61 | 0xFC60
# x[i] = 00000000_11100...00111 (左右各i个1) 
#      = (0xFFFFFFFF << (32 - i) >> 8) | (0xFFFFFFFF >> (32 - i))
#      (0 <= 0 <= 12)
# 此处用load word, save word (32bit) 足够拷贝所有数据


.TEXT   0x0000
start:
    addi    $s0, $0, 0x02FA
    sll     $s0, $s0, 16
    ori     $s0, $0, 0xF080     # $s0 <- 0x02FAF080
    addi    $s1, $0, 0          # $s1 <- 0 (i)
loop0:
    nop
loop1:          
    addi    $s0, $s0, -1       # $s0 <- $s0 - 1
    bne     $s0, $0, loop1      # if $s0 != 0 goto loop1
    addi    $s2, $0, 0xFFFF     # $s2 <- 0xFFFFFFFF
    addi    $s3, $0, 32
    sub     $s3, $s3, $s1       # $s3 <- 32 - $s1 (32 - i)
    sllv    $s4, $s2, $s3       # $s4 <- $s2 << $s3 (0xFFFFFFFF << (32 - i))
    srav    $s5, $s2, $s3       # $s5 <- $s2 >> $s3 (0xFFFFFFFF >> (32 - i))
    xor     $s6, $s4, $s5       # $s6 <- $s4 xor $s5
    sw      $s6, 0xFC60 ($0)    # LED_addr
    bne     $s3, $s0, loop0      # if (32 - i) != 0 goto loop0
    j       start