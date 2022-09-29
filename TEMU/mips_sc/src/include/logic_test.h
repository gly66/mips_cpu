#include "logic_define.h"

#define TEST_AND(v0, v1, v2)\
    AND(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_ANDI(v0, v1, v2)\
    ANDI(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_LUI(v0, v1)\
    LUI(v0);\
    li $s1, v1;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_NOR(v0, v1, v2)\
    NOR(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_OR(v0, v1, v2)\
    OR(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_ORI(v0, v1, v2)\
    ORI(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_XOR(v0, v1, v2)\
    XOR(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop\

#define TEST_XORI(v0, v1, v2)\
    XORI(v0, v1);\
    li $s1, v2;\
    bne $s0, $s1, inst_error;\
    nop