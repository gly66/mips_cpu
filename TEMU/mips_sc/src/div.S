.set noreorder
.globl main
.text

main:
 ori $v0, $zero, 0x1024
 ori $v1, $zero, 0x111
 div $v0, $v1

 mfhi $a0
 mflo $a1
 nop