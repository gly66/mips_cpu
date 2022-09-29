#define SLLV(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    sllv $s0,$t0, $t1;\

#define SLL(v0, v1)\
    li $t0, v0;\
    sll $s0,$t0, v1;\

#define SRAV(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    srav $s0,$t0, $t1;\

#define SRA(v0, v1)\
    li $t0, v0;\
    sra $s0,$t0, v1;\

#define SRLV(v0, v1)\
    li $t0, v0;\
    li $t1, v1;\
    srlv $s0,$t0, $t1;\

#define SRL(v0, v1)\
    li $t0, v0;\
    srl $s0, $t0, v1;
