set architecture arm
target remote localhost:2159
lay src
lay regs
b UND_handler
b PREF_handler
b ABT_handler
b IRQ_handler
b FIQ_handler
b __critical_error
b __no_syscall
b _start
b main
b task1
b task2
b prv_idle_task
c
