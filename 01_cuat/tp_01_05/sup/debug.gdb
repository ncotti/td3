set architecture arm
target remote localhost:2159
lay src
lay regs
b UND_handler
b PREF_handler
b ABT_handler
b IRQ_handler
b FIQ_handler
b prv_critical_error
b _start
b main
b task1
b task2
b prv_idle_task
c
