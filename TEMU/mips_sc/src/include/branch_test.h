#include "branch_define.h"

#define TEST_BEQ_E(v0,v1) \
    BEQ(v0,v1); \
    beq $t1, $t0, inst_error; \
    nop \

#define TEST_BGEZ(v0)\
    BGEZ(v0);\
    bgez $t0, inst_error;\

#define TEST_BGTZ_B(v0) \
    BGTZ(v0); \
    bgtz $t0, good;\

#define TEST_BGTZ_NB(v0) \
    BGTZ(v0); \
    bgtz $t0, inst_error;

#define TEST_BLEZ_NSE(v0) \
    BLEZ(v0); \
    blez $t0, inst_error;\
    nop \

#define TEST_BLEZ_SE(v0) \
    BLEZ(v0); \
    blez $t0, good;\
    nop \

#define TEST_BLTZ_B(v0)\
    BLTZ(v0);\
    bltz $t0, good;\
    nop\

#define TEST_BLTZ_NB(v0)\
    BLTZ(v0);\
    bltz $t0, inst_error;\
    nop\

#define TEST_BGEZAL_NB(v0)\
    BGEZAL(v0);\
    bgezal $t0, inst_error;\ 

#define TEST_BGEZAL_B(v0)\
    BGEZAL(v0);\
    bgezal $t0, good;\ 

#define TEST_BLTZAL_NB(v0)\
    BLTZAL(v0);\
    bltzal $t0, inst_error;\ 

#define TEST_BLTZAL_B(v0)\
    BLTZAL(v0);\
    bltzal $t0, good;\ 

// #define TEST_BLEZ_NSE(v0,v1,v3) \
//     BLEZ(v0,v1); \
//     add $s1, $pc, 0; \
//     bne $s0, $s1, insr_error; \
//     nop \
    
// #define TEST_J(v0) \
//     J(v0); \
//     and $t1, $t0, 0xF0000000; \
//     li $t2, v0; \
//     sll $t3, $t2, 0x00000002; \
//     add $s0, $t1, $t3;\
//     add $s1, $pc, 0; \
//     bne $s0, $s1, insr_error; \
//     nop \

// #define TEST_JAL(v0) \
//     JAL(v0); \
//     and $t1, $t0, 0xF0000000; \
//     li $t2, v0; \
//     sll $t3, $t2, 0x00000002; \
//     add $s0, $t1, $t3;\
//     add $s1, $pc, 0; \
//     sub $s2, $s0, $s1;\
//     addi $t4, $t0, 0x00000008;\
//     sub $s3, $ra, $t4;\
//     or $s4, $s2, $s3;\
//     bne $s4, $zero, insr_error; \
//     nop \
