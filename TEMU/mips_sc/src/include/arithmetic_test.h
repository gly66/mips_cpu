#include "arithmetic_define.h"

#define TEST_ADD(v0, v1, v2)\
    ADD(v0,v1);\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_ADDI(v0, v1, v2)\
    ADDI(v0,v1);\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_ADDI_OV(v0, v1, v2)\
    ADDI(v0,v1);\
    li $s0, v2;\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_ADD_OV(v0, v1, v2)\
    ADD(v0,v1);\
    li $s0, v2;\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_ADDU(v0, v1, v2)\
    ADDU(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_ADDIU(v0, v1, v2)\
    ADDIU(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SUB(v0, v1, v2)\
    SUB(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SUB_OV(v0, v1, v2)\
    SUB(v0, v1)\
    li $s0, v2;\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SUBU(v0, v1, v2)\
    SUBU(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop

#define TEST_SLT(v0, v1, v2)\
    SLT(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SLTI(v0, v1, v2)\
    SLTI(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SLTU(v0, v1, v2)\
    SLTU(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_SLTIU(v0, v1, v2)\
    SLTIU(v0, v1)\
    li $s1, v2;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_DIV(v0, v1, v2,v3)\
    DIV(v0, v1)\
    li $s1, v2;\
    mflo $s0;\
    bne $s1, $s0, inst_error;\
    li $s1, v3;\
    mfhi $s0;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_DIVU(v0, v1, v2,v3)\
    DIVU(v0, v1)\
    li $s1, v2;\
    mflo $s0;\
    bne $s1, $s0, inst_error;\
    li $s1, v3;\
    mfhi $s0;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_MULT(v0, v1, v2,v3)\
    MULT(v0, v1)\
    li $s1, v2;\
    mflo $s0;\
    bne $s1, $s0, inst_error;\
    li $s1, v3;\
    mfhi $s0;\
    bne $s1, $s0, inst_error;\
    nop\

#define TEST_MULTU(v0, v1, v2,v3)\
    MULTU(v0, v1)\
    li $s1, v2;\
    mflo $s0;\
    bne $s1, $s0, inst_error;\
    li $s1, v3;\
    mfhi $s0;\
    bne $s1, $s0, inst_error;\
    nop