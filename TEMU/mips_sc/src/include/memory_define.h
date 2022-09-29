#define B(v0, v1, v2)\
    li $t0, v0; \
    li $t1, v1; \
    sb $t0, v2($t1); \
    lb $s0, v2($t1);\

#define BU(v0, v1, v2)\
    li $t0, v0; \
    li $t1, v1; \
    sb $t0, v2($t1); \
    lbu $s0, v2($t1);\

#define H(v0, v1, v2)\
    li $t0, v0; \
    li $t1, v1; \
    sh $t0, v2($t1); \
    lh $s0, v2($t1);\

#define HU(v0, v1, v2)\
    li $t0, v0; \
    li $t1, v1; \
    sh $t0, v2($t1); \
    lhu $s0, v2($t1);\

#define W(v0, v1, v2)\
    li $t0, v0; \
    li $t1, v1; \
    sw $t0, v2($t1); \
    lw $s0, v2($t1);