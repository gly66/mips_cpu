.set noat
.set noreorder
.globl main
.text
main:
    ori $at, $zero, 0x100      #$at ($1) =0x100
    sw  $at, 0x0($zero)
    ori $at,$zero, 0x200      # $at($1)=0x200
    syscall                    #syscall,转移至异常处理程序入口地址0x100
    lw  $at, 0x0($zero)        #$at($1)=0x100
    lui $v1, 0xffff           # $v1 ($2) = 0xffff0000
    lui $v0, 0x8000            #$v2 ($3) =0x80000000
    add $a0, $v1, $v0            # $a0($4)=$v1($2)+$v2($3)发生溢出

    j success
    nop


.org 0x100
    mfc0 $a1, $13               # $a1 ($5) = cause, cause[6:2]=0x08
    ori  $a2, $zero, 0x20       #$a2 ($6) =0x00000020
    beq  $a1, $a2, exc_eret
    nop
    mfc0 $a1, $13               # $a1 ($5) = cause, cause[6:2] = 0x0C
    ori  $a2, $zero, 0x30       # $a2 ($6)=0x00000030
    beq  $a1, $a2, exc_eret
    nop
    j    error
    nop



error:
    ori $a3, $zero, 0xffff          #$a3 ($7) = 0x0000ffff
j loop
    nop

success:
    add $a0,$v1, $at           # $a0 ($4) = 0xffff0100
loop:
    j loop
    nop


.org 0x300
exc_eret:
    addiu $a3, $a3, 0x1
    mfc0  $t1, $14
    ori   $t0, $zero, 0x4
    add   $t1, $t1, $t0
    mtc0  $t1, $14
    nop
.set mips32
    eret
.set mips1
    nop
    nop
    nop
