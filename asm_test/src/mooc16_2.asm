
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
#      = (0x00FFFFFF << (24 - i)) | (0x00FFFFFF >> (24 - i))
#      (0 <= i <= 12)
# 此处用load word, save word (32bit) 足够拷贝所有数据


.DATA
.TEXT   0x0000
start:

    addi    $s1, $0, 0
loop0:
    # addi    $s0, $0, 0x02FA
    # sll     $s0, $s0, 16
    # ori     $s0, $0, 0xF080
    addi    $s0, $0, 0x0000
    sll     $s0, $s0, 16
    ori     $s0, $0, 0x0020
loop_sleep0:
    addi    $s0, $s0, -1
    bne     $s0, $0, loop_sleep0

    addi    $s2, $0, 0x0FFF
    addi    $t0, $0, 3
    sllv    $s3, $s2, $t0
    addi    $t1, $0, 12
    subu    $t1, $t1, $s1
    srlv    $s4, $s2, $t1   
    sllv    $s5, $s2, $t1
    xor     $s6, $s4, $s5
    xor     $s6, $s6, $0
    sw      $s6, 0xFC60 ($0)    # LED_addr

    addi    $s1, $s1, 1
    addi    $t0, $0, 12
    bne     $s1, $t0, loop0
    
    j       start