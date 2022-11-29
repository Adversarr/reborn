# Minisys汇编程序设计1
# LED:         0xFFFFFC60 - 0xFFFFFC62 (3 byte)
# DIP switch:  0xFFFFFC70 - 0xFFFFFC72 (3 byte)

.DATA   0x0000
.TEXT   0x0000
start:  
    addi    $s0, $0, 0
loop:
    sw      $s0, 0xFC60 ($0) 
    sw      $s1, 0xFC64 ($0) 
    addi    $s0, $s0, 1
    srl     $s1, $s0, 16
    j       loop
    j       start
