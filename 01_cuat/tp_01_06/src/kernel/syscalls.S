/******************************************************************************
* Syscall table
******************************************************************************/
.data
.global syscall_table
syscall_table:
// 0
.word __critical_error
.word __read_privileged_data
.word __write_privileged_data
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

// 10
.word __get_random
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

// 20
.word __testing_syscall0
.word __testing_syscall1
.word __testing_syscall2
.word __testing_syscall3
.word __testing_syscall4
.word __testing_syscall5
.word __testing_syscall6
.word __testing_syscall7
.word __no_syscall
.word __no_syscall

// 30
.word __timer_init
.word __timer_resume
.word __timer_pause
.word __timer_reset
.word __timer_load_ms
.word __timer_load_us
.word __timer_set_mode
.word __timer_enable_interrupt
.word __timer_disable_int
.word __timer_clear_interrupt

// 40
.word __timer_time_ms
.word __timer_time_us
.word __timer_interrupted
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

// 50
.word __gic_enable_interrupt
.word __gic_disable_interrupt
.word __gic_get_id
.word __gic_get_priority
.word __gic_clear_interrupt
.word __gic_set_swi
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

// 60
.word __scheduler_init
.word __scheduler_add_task
.word __scheduler_start
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

// 70
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall
.word __no_syscall

.text
__no_syscall:
    b .

/******************************************************************************
* Syscall calling interface. The number in "syscallX" indicates the amount of
* parameters that the syscall takes. For example the function "foo(a, b, c)"
* should use "syscall3(a, b, c, SVC_ID)".
******************************************************************************/
.section .syscall, "ax", %progbits
.global syscall0
.type syscall0, %function
syscall0:
    push {r7}
    mov r7, r0
    svc #0
    pop {r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall1
.type syscall1, %function
syscall1:
    push {r7}
    mov r7, r1
    svc #0
    pop {r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall2
.type syscall2, %function
syscall2:
    push {r7}
    mov r7, r2
    svc #0
    pop {r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall3
.type syscall3, %function
syscall3:
    push {r7}
    mov r7, r3
    svc #0
    pop {r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall4
.type syscall4, %function
syscall4:
    push {r7}
    ldr r7, [sp, #4]
    svc #0
    pop {r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall5
.type syscall5, %function
syscall5:
    push {r4, r7}
    ldr r4, [sp, #8]
    ldr r7, [sp, #12]
    svc #0
    pop {r4, r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall6
.type syscall6, %function
syscall6:
    push {r4, r5, r7}
    ldr r4, [sp, #12]
    ldr r5, [sp, #16]
    ldr r7, [sp, #20]
    svc #0
    pop {r4, r5, r7}
    mov pc, lr

.section .syscall, "ax", %progbits
.global syscall7
.type syscall7, %function
syscall7:
    push {r4-r7}
    ldr r4, [sp, #16]
    ldr r5, [sp, #20]
    ldr r6, [sp, #24]
    ldr r7, [sp, #28]
    svc #0
    pop {r4-r7}
    mov pc, lr
