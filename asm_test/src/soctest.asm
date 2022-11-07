# 数据定义的首地址
.data  0x0000
    buf:    .word  0x00000055, 0x000000AA   # 定义数据
    buf2:   .word 0x00000000
    DELAY:  .word 0x3F9409                  # 0.5秒延时计数,只是一个大概数字
    LED:    .word 0XAAAAAAAA                # 要显示的LED数据
    MASK:   .word 0XFFFFFFFF

# 代码段定义开始
.text 0x0000
start:  ori $at,$zero,1         #寄存器初始化
        ori $v0,$zero,2
        ori $v1,$zero,3
        ori $a0,$zero,4
        ori $a1,$zero,5
        ori $a2,$zero,6
        ori $a3,$zero,7
        ori $t0,$zero,8
        ori $t1,$zero,9
        ori $t2,$zero,10
        ori $t3,$zero,11
        ori $t4,$zero,12
        ori $t5,$zero,13
        ori $t6,$zero,14
        ori $t7,$zero,15
        ori $s0,$zero,16
        ori $s1,$zero,17
        ori $s2,$zero,18
        ori $s3,$zero,19
        ori $s4,$zero,20
        ori $s5,$zero,21
        ori $s6,$zero,22
        ori $s7,$zero,23
        ori $t8,$zero,24
        ori $t9,$zero,25
        ori $i0,$zero,26
        ori $i1,$zero,27
        ori $s9,$zero,28
        ori $sp,$zero,29
        ori $s8,$zero,30
        ori $ra,$zero,31
        lw $v0,buf($zero)       
        lw $v1,buf($a0)         # buf+4
        add $at,$v0,$v1
        sw $at,8($zero)         # 写buf2
        subu $a0,$v1,$v0
        slt $a0,$v0,$at
        and $at,$v1,$a3
        or $a2,$v0,$at
        xor $a3,$v0,$v1
        nor $a2,$a1,$at
lop:    beq $v1,$v0,lop
lop1:   sub $v0,$v0,$a1
        bne $a1,$v0,lop1
        beq $at,$at,lop2
        nop
lop2:   jal subp
        j next
subp:   jr $ra 
next:   addi $v0,$zero,0x99
        ori $v1,$zero,0x77
        sll $v1,$v0,4 
        srl $v1,$v0,4 
        srlv $v1,$v0,$at
        lui $a2,0x9988
        sra $a3,$a2,4
        addi $v0,$zero,0
        addi $v1,$zero,2
        sub  $at,$v0,$v1

# 以下部分是下载后让LED显示，如果只仿真测试CPU，下面的部分可以删除，只留最后一句 j start
disp:lui    $28,0XFFFF          # 让$28为0FFFF0000作为端口地址的高16位
        ori     $28,$28,0XF000  # $28端口是系统的I/O地址的高20位
        lw  $3, LED($zero)      # 得到要显示的值
        srl    $4,$3,16         # $4得到$3的高16位
        sw  $3,0XC60($28)       # 输出低16位LED
        sw  $4,0XC62($28)       # 输出高6位LED
        lw    $5, MASK($zero)   # 得到掩码 
        xor   $3,$3,$5          # $3取反
        sw    $3, LED($zero)    # 存储取反后的数
        jal dely
        j   disp
dely:   lw    $29,DELAY($zero)  # 延迟大约0.5秒
dlop:   addi $29,$29,-1
        bne $29,$0,dlop
        jr  $31

