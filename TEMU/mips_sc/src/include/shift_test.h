#include "shift_define.h"

#define TEST_SLLV(v0, v1, v2)\
    SLLV(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_SLL(v0, v1, v2)\
    SLL(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_SRAV(v0, v1, v2)\
    SRAV(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_SRA(v0, v1, v2)\
    SRA(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_SRLV(v0, v1, v2)\
    SRLV(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_SRL(v0, v1, v2)\
    SRL(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop