set architecture arm
target remote localhost:2159
lay regs
b SVC_handler
b UND_handler
b PREF_handler
b ABT_handler
b IRQ_handler
b FIQ_handler
b startup
b _start
b main
c
