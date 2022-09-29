#include "trap.h"
#include "include/memory_test.h"
   .globl main
   .set noreorder
   .text
main:

   TEST_Byte(0x1122FF44, 0x80106760, 0x00000001, 0x00000044)
   TEST_ByteU(0x112244FF, 0x80106760, 0x00000001, 0x000000FF)
   TEST_H(0x1122AA44, 0x80106760, 0x00000002, 0xFFFFAA44)
   TEST_HU(0xFFEEDDCC, 0x80106760, 0x00000002, 0x0000DDCC)
   TEST_W(0xFFEEDDCC, 0x80106760, 0x000000001, 0xFFEEDDCC)
   HIT_GOOD_TRAP		#stop temu

inst_error:
   HIT_BAD_TRAP #report wrong
