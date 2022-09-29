#include "datamove_define.h"

#define TEST_HI(v0)\
    HI(v0);\
    li $s0 v0;\
    bne $t1, $s0, inst_error;\
    nop\

#define TEST_LO(v0)\
    LO(v0);\
    li $s0 v0;\
    bne $t1, $s0, inst_error;\
    nop\
