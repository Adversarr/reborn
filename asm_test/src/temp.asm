.DATA   0x0000
.TEXT   0x0000
start:  
    lw      $s0, 0xFC70 ($0) 
    sw      $s0, 0xFC60 ($0) 
    j       start