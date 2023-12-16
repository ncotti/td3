set architecture arm
target remote localhost:2159
lay regs
b RESET_handler
b _start
b boot
b SVC_handler
b main.s:6
c
