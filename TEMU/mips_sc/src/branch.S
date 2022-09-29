#include "trap.h"
#include "include/branch_test.h"
   .globl main
   .set noreorder
   .text
main:

    TEST_BEQ_E(0x0022FF44,0x0022FF45)
    TEST_BGEZ(-1)
    TEST_BGTZ_NB(0)
    #TEST_BGTZ_B(1)

    TEST_BLEZ_NSE(1)
   #  TEST_BLEZ_SE(0)  
   TEST_BLTZ_NB(0)
   #TEST_BLTZ_B(-1)
   TEST_BGEZAL_NB(-1)
   #TEST_BGEZAL_B(0)
   TEST_BLTZAL_NB(0)
   TEST_BLTZAL_B(-1)
    #HIT_GOOD_TRAP		#stop temu

 inst_error:
   HIT_BAD_TRAP #report wrong 

good:
    HIT_GOOD_TRAP

# .org 0x380
# except:
#  eret;
