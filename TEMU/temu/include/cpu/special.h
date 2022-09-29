#ifndef __SPECIAL_H__
#define __SPECIAL_H__

make_helper(inv);
make_helper(temu_trap);
make_helper(bad_temu_trap);

// privileged instr
make_helper(eret);
make_helper(mfc0);
make_helper(mtc0);
#endif
