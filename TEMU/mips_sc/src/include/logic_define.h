#define AND(v0, v1) \
    li $t0, v0; \
    li $t1, v1; \
    and $s0, $t0, $t1;\

#define  ANDI(v0,v1)\
    li $t0, v0;\
    andi $s0, $t0, v1;\

#define LUI(v0)\
    lui $s0, v0;\

#define NOR(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    nor $s0, $t0, $t1;\

#define OR(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    or $s0, $t0, $t1;\

#define  ORI(v0,v1)\
    li $t0, v0;\
    ori $s0, $t0, v1;\

#define XOR(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    xor $s0, $t0, $t1; \

#define  XORI(v0,v1)\
    li $t0, v0;\
    xori $s0, $t0, v1;