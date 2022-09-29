#define ADD(v0,v1) \
    li $t0, v0; \
    li $t1, v1; \
    add $s0, $t0, $t1; \

#define ADDI(v0,v1)\
    li $t0, v0; \
    lui $t2, v1;\
    sra $t1, $t2, 16;\
    addi $s0, $t0, v1; \

#define ADDU(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    addu $s0, $t0, $t1;\

#define ADDIU(v0,v1)\
    li $t0, v0;\
    addiu $s0, $t0, v1;\

#define SUB(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    sub $s0, $t0, $t1;\

#define SUBU(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    subu $s0, $t0, $t1;\

#define SLT(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    slt $s0, $t0, $t1;\

#define SLTI(v0,v1)\
    li $t0, v0;\
    slti $s0, $t0, v1;\

#define SLTU(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    sltu $s0, $t0, $t1;\

#define SLTIU(v0,v1)\
    li $t0, v0;\
    sltiu $s0, $t0, v1;\

#define DIV(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    div $zero, $t0, $t1;\

#define DIVU(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    divu $zero, $t0, $t1;\

#define MULT(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    mult $t0, $t1;\

#define MULTU(v0,v1)\
    li $t0, v0;\
    li $t1, v1;\
    multu $t0, $t1;