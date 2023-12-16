set architecture arm
target remote localhost:2159
lay regs
b SVC_handler
b UND_handler
b PREF_handler
b ABT_handler
b main:asm.s:6
b main_asm.s:9
b _start
b main
b IRQ_handler
b timer_irq_handler
b timer_irq_asm
c
