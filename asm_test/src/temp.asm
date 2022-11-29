.DATA
.TEXT   0x0000
start:
    addi    $s1, $0, 0
    lui     $s1, 0x1234
    ori     $s1, $s1, 0x5678
    j       start