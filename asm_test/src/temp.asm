.DATA   0x0000
.TEXT   0x0000
start:  
    lw      $s0, 0xFC70 ($0) 
    lw      $s1, 0xFC74 ($0) 
    sw      $s0, 0xFC60 ($0) 
    sw      $s1, 0xFC64 ($0) 
    j       start
