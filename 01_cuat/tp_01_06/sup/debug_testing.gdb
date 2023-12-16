# This gdb file has the relevant breakpoints used when running system tests.
# Remember to change the variable "gdb_script" in the Makefile, and enable
# the "ENABLE_TESTING" definition in the "config.h" file
set architecture arm
target remote localhost:2159
lay src
lay regs
b _start
b __critical_error
b __no_syscall
b test_system
b test_failed
b test_success
b prv_testing_task1
b prv_testing_task2
b testing_asm.S:180
b testing_asm.S:250
c