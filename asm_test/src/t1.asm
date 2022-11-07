.DATA  0x00000000
    buf:    .WORD 0x000000FF, 0x55005500

.TEXT
start:  
    addi    $t0, $0, 0
    lw      $0, buf ($t0)   # $v0 <- buf[0] = 0x000000FF
    addi    $t0, $t0, 4
    lw      $v1, buf ($t0)  # $v0 <- buf[4] = 0x55005500 
    add     $v0, $v0, $v1   # $v0 <- $v0 + $v1 = 0x550055FF
    addi    $t0, $t0, 4
    sw      $v0, buf ($0)   # buf[8] <- $v0 = 0x550055FF
    j       start
