.set noat
.set noreorder
.globl main
.text
main:
lui $at, 0x1234
lui $v0, 0x1230
ori $at, $at, 0xabcd
ori $v0, $v0, 0xabcd
add $v1, $at, $v0
mult $v0, $v1
mfhi $a0
mflo $a1

nop