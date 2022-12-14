#include "trap.h"
#include "include/arithmetic_test.h"
   .set noat
   .globl main
   .set noreorder
   .text
main:

   TEST_SLTU(0x80000000, 0x00000001, 0x00000000)
   TEST_SLTU(0x00000001, 0x80000000, 0x00000001)
   TEST_SLTU(0x00000001, 0x00000002, 0x00000001)
   TEST_SLTU(0x00000002, 0x00000001, 0x00000000)
   TEST_SLTU(0xFFFFFFFF, 0xFFFFFFF0, 0x00000000)
   TEST_SLTU(0xFFFFFFFF, 0x00000000, 0x00000000)
   TEST_SLTU(0x00000001, 0x00000001, 0x00000000)

   TEST_SLTIU(0x80000000, 0x00000001, 0x00000000)
   TEST_SLTIU(0x00000001, 0x0000FFFF, 0x00000001)
   TEST_SLTIU(0x12345678, 0x00001234, 0x00000000)
   TEST_SLTIU(0x00005678, 0x0000789A, 0x00000001)
   TEST_SLTIU(0xFFFFFFFF, 0x00008000, 0x00000000)
   TEST_SLTIU(0x80000000, 0x0000FFFF, 0X00000001)
   TEST_SLTIU(0x00000001, 0x00000001, 0x00000000)

   HIT_GOOD_TRAP		#stop temu

inst_error:
   HIT_BAD_TRAP

.org 0x00000380
except:
   eret;