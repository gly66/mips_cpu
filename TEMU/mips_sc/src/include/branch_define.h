#define BEQ(v0,v1) \
    li $t0, v0; \
    li $t1, v1; \
    nop\

#define BGEZ(v0) \
    li $t0, v0; \
    nop\

#define BGTZ(v0) \
    li $t0, v0; \
    nop\

#define BLEZ(v0) \
    li $t0, v0; \
    nop\

#define BLTZ(v0) \
    li $t0, v0; \
    nop\

#define BGEZAL(v0) \
    li $t0, v0; \

#define BLTZAL(v0) \
    li $t0, v0; \

#define J(v0) \
    add $t0, $pc, 0;\
    j v0;\

#define JAL(v0) \
    add $t0, $pc, 0;\
    jal v0;\
