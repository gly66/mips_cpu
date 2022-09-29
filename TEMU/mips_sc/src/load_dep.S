.set noat
.set noreorder
.globl main
.text

main:
 ori $at, $zero, 0xabab
 ori $v0, $zero, 0xabab
 sw $at, 0x0($zero)
 ori $at, $zero, 0x0000
 lw  $v1, 0x0($zero)
 beq $v0, $v1, BR1
 nop
 ori $at, $zero, 0x1234
 nop
 j _exit

BR1: 
 ori $at, $zero, 0xfefe
 nop

_exit:
 ori $a0, $zero, 0xffff

loop:
 j loop
 nop