# This gdb file has the relevant breakpoints used when running system tests.
# Remember to change the variable "gdb_script" in the Makefile, and enable
# the "ENABLE:TESTING" definition in the "config.h" file
set architecture arm
target remote localhost:2159
lay src
lay regs
b _start
b prv_critical_error
b test_system
b test_failed
b test_success
c