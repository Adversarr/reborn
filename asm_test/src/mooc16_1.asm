# Minisys汇编程序设计1
# 独特的 minisys1A I/O编址方式: 
# 0xFC70 -> LED[15:0], 0xFC74 -> LED[23:16]
# 0xFC60 <- DIP[15:0], 0xFC64 <- DIP[23:16]
# tested

.DATA   0x0000
.TEXT   0x0000
start:  
    lw      $s0, 0xFC70 ($0) 
    lw      $s1, 0xFC74 ($0) 
    sw      $s0, 0xFC60 ($0) 
    sw      $s1, 0xFC64 ($0) 
    j       start
