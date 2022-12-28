.data
led: .word 0xFFFFFC60
digits: .word 0xFFFFFC00
maxui: .word 0xFFFFFFFF
beep: .word 0xFFFFFD10
switch: .word 0xFFFFFC70
enable_led: .word 0xFFFFFFFF
kbd: .word 0xFFFFFC10

.text
st:
  addi $12, $0, 0x00 # $12 = 0
start:
  addiu $12, $12, 0x01 # $12 = $12 + 1
  lw $13, kbd($0)
  sw $12, 0($13)
  lw $12, 0x2($13)
  lw $1, led($0)
  sw $12, 0($1)

  lw $1, enable_led($0)  # $1 = 0xFFFF_FFFF
  lw $2, digits($0)   # $2 = digits
  sw $1, 0x04($2)  # enable digits
  lw $3, beep($0)    # $3 = beep
  lw $10, switch($0)  # $10 = switch
  lw $11, 0($10)      # $11 = switch data
  sw $11, 0x00($2)  # digits = switch data
  sw $11, 0xFD10($0)   # beep = switch data
  j start
  nop
