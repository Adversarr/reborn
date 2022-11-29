# Minisys汇编程序设计1
# LED:         0xFFFFFC60 - 0xFFFFFC62 (3 byte)
# DIP switch:  0xFFFFFC70 - 0xFFFFFC72 (3 byte)

.DATA   0x0000
.TEXT   0x0000
start:  
    lw      $s0, 0xFC70 ($0) 
    lw      $s0, 0xFC74 ($0) 
    sw      $s0, 0xFC60 ($0) 
    sw      $s1, 0xFC64 ($0) 
    j       start
