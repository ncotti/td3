#include "config.h"

#ifdef ENABLE_TESTING

#include "op_modes.h"
#include "test_codes.h"
#include "syscalls.h"
.include "mmu_macros.S"
.include "syscalls_macros.S"

.macro ASSERT_EQ reg, value
    teq \reg, \value
    bne test_failed
.endm

.macro ASSERT_NEQ reg, value
    teq \reg, \value
    beq test_failed
.endm

/******************************************************************************
* Functions
******************************************************************************/
/// @brief Make a complete system check. Each test function will return in case
///   of success. In case of error, they will jump to "test_failed" and
///   block execution. The system will shut down after the tests are completed.
.text
.global test_system
.type test_system, %function
test_system:
    ldr sp, =testing_stack_top
    cpsie aif, #USR_MODE
    bl prv_test_svc
    bl prv_test_undef
    bl prv_test_alignment_fault
    bl prv_test_data_read_fault
    bl prv_test_data_write_fault
    bl prv_test_syscalls
    //bl test_software_irq  // Broken with scheduler implementation
    bl test_timers
    #ifdef ENABLE_MEMORY_MAPPING_FROM_ABORT
    bl prv_test_table_walk_fault
    #endif
    // Scheduler test should always be the last test executed
    #ifdef ENABLE_TEST_SCHEDULER
    bl prv_test_scheduler
    #endif
    b test_success

.text
.type prv_test_svc, %function
prv_test_svc:
    mov r0, #TESTING_START
    svc #SVC_TEST
    SYS_ASM get_svc_return
    ASSERT_EQ r0, #TESTING_SVC
    mov pc, lr

.text
.type prv_test_undef, %function
prv_test_undef:
    mov r0, #TESTING_START
    .word 0xe7f000f0
    SYS_ASM get_und_return
    ASSERT_EQ r0, #TESTING_UNDEF
    mov pc, lr

.text
.type prv_test_alignment_fault, %function
prv_test_alignment_fault:
    mov r0, #TESTING_START
    mov r1, #1
    ldr r1, [r1]
    SYS_ASM get_abt_return
    ASSERT_EQ r0, #TESTING_ALIGNMENT_FAULT
    mov pc, lr

.text
.type prv_test_data_read_fault, %function
prv_test_data_read_fault:
    mov r0, #TESTING_START
    ldr r1, =privileged_kernel_data
    ldr r1, [r1]
    SYS_ASM get_abt_return
    ASSERT_EQ r0, #TESTING_DATA_READ_FAULT
    mov pc, lr

.text
.type prv_test_data_write_fault, %function
prv_test_data_write_fault:
    mov r0, #TESTING_START
    ldr r1, =read_only_var
    str r1, [r1]
    SYS_ASM get_abt_return
    ASSERT_EQ r0, #TESTING_DATA_WRITE_FAULT
    mov pc, lr

.text
.type prv_test_syscalls, %function
prv_test_syscalls:
    push {r12, lr}
    mov r0, #TESTING_START
    bl privileged_kernel_function
    ASSERT_EQ r0, #TESTING_KERNEL_FUNCTION
    SYS_ASM get_pref_return
    ASSERT_EQ r0, #TESTING_INSTRUCTION_PERMISSION_ABORT

    mov r0, #TESTING_START
    bl privileged_kernel_function
    ASSERT_EQ r0, #TESTING_KERNEL_FUNCTION

    cps #USR_MODE
    mov r0, #TESTING_START
    SYS_ASM privileged_kernel_function
    ASSERT_EQ r0, #TESTING_KERNEL_FUNCTION
    bl test_syscalls
    pop {r12, lr}
    mov pc, lr

.text
.type prv_test_table_walk_fault, %function
prv_test_table_walk_fault:
    push {r4, r12}
    mov r4, #1000
    loop_table_walk_fault:
        SYS_ASM random
        ldr r1, [r0]
        mov r1, #55
        str r1, [r0]
        mov r1, #0
        ldr r1, [r0]
        subs r4, r4, #1
        bgt loop_table_walk_fault
    pop {r4, r12}
    mov pc, lr

#ifdef ENABLE_TEST_SCHEDULER
.text
.type prv_test_scheduler, %function
prv_test_scheduler:
    push {r12, lr}
    bl scheduler_init

    ldr r0, =prv_testing_task1
    ldr r1, =testing_task1_stack_top
    ldr r2, =testing_table1_addr
    bl scheduler_add_task

    ldr r0, =prv_testing_task2
    ldr r1, =testing_task2_stack_top
    ldr r2, =testing_table1_addr
    bl scheduler_add_task

    bl scheduler_start

.text
.type prv_testing_task1, %function
prv_testing_task1:
    // Signal that task1 executed
    ldr r0, =last_task_executed
    ldr r1, [r0]
    ASSERT_EQ r1, #TESTING_START
    mov r1, #TESTING_TASK1
    str r1, [r0]

    // Store all registers
    ldr r0, =task1_stack
    str sp, [r0]
    mov r0, #0
    mov r1, #1
    mov r2, #2
    mov r3, #3
    mov r4, #4
    mov r5, #5
    mov r6, #6
    mov r7, #7
    mov r8, #8
    mov r9, #9
    mov r10, #10
    mov r11, #11
    mov r12, #12
    mov r14, #14
    WFI

    // Check that task2 has been executed before
    push {r0, r1}
    ldr r0, =last_task_executed
    ldr r1, [r0]
    ASSERT_EQ r1, #TESTING_TASK2
    mov r1, #TESTING_TASK1
    str r1, [r0]
    pop {r0, r1}

    // Check that all registers have the same value
    ASSERT_EQ r0, #0
    ASSERT_EQ r1, #1
    ASSERT_EQ r2, #2
    ASSERT_EQ r3, #3
    ASSERT_EQ r4, #4
    ASSERT_EQ r5, #5
    ASSERT_EQ r6, #6
    ASSERT_EQ r7, #7
    ASSERT_EQ r8, #8
    ASSERT_EQ r9, #9
    ASSERT_EQ r10, #10
    ASSERT_EQ r11, #11
    ASSERT_EQ r12, #12
    ASSERT_EQ r14, #14
    ldr r0, =task1_stack
    ldr r0, [r0]
    ASSERT_EQ r0 sp
    WFI
    b prv_testing_task1

.text
.type prv_testing_task2, %function
prv_testing_task2:
    // Signal that task2 executed, check that task1 has been executed
    ldr r0, =last_task_executed
    ldr r1, [r0]
    ASSERT_EQ r1, #TESTING_TASK1
    mov r1, #TESTING_TASK2
    str r1, [r0]

    // Store all registers
    ldr r0, =task2_stack
    str sp, [r0]
    mov r0, #100
    mov r1, #101
    mov r2, #102
    mov r3, #103
    mov r4, #104
    mov r5, #105
    mov r6, #106
    mov r7, #107
    mov r8, #108
    mov r9, #109
    mov r10, #110
    mov r11, #111
    mov r12, #112
    mov r14, #114
    WFI

    // Check that task1 has been executed before
    push {r0, r1}
    ldr r0, =last_task_executed
    ldr r1, [r0]
    ASSERT_EQ r1, #TESTING_TASK1
    pop {r0, r1}

    // Check that all registers have the same value
    ASSERT_EQ r0, #100
    ASSERT_EQ r1, #101
    ASSERT_EQ r2, #102
    ASSERT_EQ r3, #103
    ASSERT_EQ r4, #104
    ASSERT_EQ r5, #105
    ASSERT_EQ r6, #106
    ASSERT_EQ r7, #107
    ASSERT_EQ r8, #108
    ASSERT_EQ r9, #109
    ASSERT_EQ r10, #110
    ASSERT_EQ r11, #111
    ASSERT_EQ r12, #112
    ASSERT_EQ r14, #114
    ldr r0, =task2_stack
    ldr r0, [r0]
    ASSERT_EQ r0 sp
    b test_success
    b prv_testing_task2

.data
last_task_executed: .word TESTING_START
task1_stack: .word TESTING_START
task2_stack: .word TESTING_START
#endif

/// @brief Reaching here means that some test failed, and execution was aborted.
.text
.type test_failed, %function
.global test_failed
test_failed:
    b .

/// @brief Reaching here means that all tests passed successfully.
.text
.type test_success, %function
.global test_success
test_success:
    b .

.section .stack, "aw", %nobits
.space 0x100
.balign 8
testing_stack_top:

.space 0x100
.balign 8
testing_task1_stack_top:

.space 0x100
.balign 8
testing_task2_stack_top:

#endif // ENABLE_TESTING