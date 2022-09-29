#include "memory_define.h"

#define TEST_Byte(v0, v1, v2, v3) \
    B(v0, v1, v2);\
    li $s1, v3; \
    bne $s0, $s1, inst_error; \
    nop\

#define TEST_ByteU(v0, v1, v2, v3) \
    BU(v0, v1, v2);\
    li $s1, v3;\
    bne $s0, $s1, inst_error; \
    nop\

#define TEST_H(v0, v1, v2, v3) \
    H(v0, v1, v2);\
    li $s1, v3; \
    bne $s0, $s1, inst_error; \
    nop\

#define TEST_HU(v0, v1, v2, v3)\
    HU(v0, v1, v2);\
    li $s1, v3;\
    bne $s0, $s1, inst_error; \
    nop\

#define TEST_W(v0, v1, v2, v3)\
    W(v0, v1, v2);\
    li $s1, v3;\
    bne $s0, $s1, inst_error; \
    nop