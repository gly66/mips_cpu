#define HI(v0) \
    li $t0, v0; \
    mthi $t0; \
    mfhi $t1; \

#define LO(v0) \
    li $t0, v0; \
    mtlo $t0; \
    mflo $t1; \
