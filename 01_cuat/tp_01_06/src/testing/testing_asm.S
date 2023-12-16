#include "config.h"

#ifdef ENABLE_TESTING

#include "op_modes.h"
#include "test_codes.h"
#include "syscall_id.h"
.include "mmu_macros.S"

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
    bl prv_test_public_data
    bl prv_test_undef
    bl prv_test_alignment_fault
    bl prv_test_data_read_fault
    bl prv_test_data_write_fault
    bl test_syscalls
    bl test_timers
    #ifdef ENABLE_NEON
    bl prv_test_neon
    #endif
    #ifdef ENABLE_MEMORY_MAPPING_FROM_ABORT
    bl prv_test_table_walk_fault
    #endif
    // Scheduler test should always be the last test executed
    #ifdef ENABLE_TEST_SCHEDULER
    bl prv_test_scheduler
    #endif
    b test_success

.text
.type prv_test_public_data, %function
prv_test_public_data:
    ldr r0, =testing_public_data
    ldr r0, [r0]
    ASSERT_EQ r0, #TESTING_PUBLIC_DATA
    mov pc, lr

.text
.type prv_test_undef, %function
prv_test_undef:
    .word 0xe7f000f0
    ldr r0, =und_return
    ldr r0, [r0]
    ASSERT_EQ r0, #TESTING_UNDEF
    mov pc, lr

.text
.type prv_test_alignment_fault, %function
prv_test_alignment_fault:
    mov r0, #1
    ldr r0, [r0]
    ldr r0, =abt_return
    ldr r0, [r0]
    ASSERT_EQ r0, #TESTING_ALIGNMENT_FAULT
    mov pc, lr

.text
.type prv_test_data_read_fault, %function
prv_test_data_read_fault:
    ldr r0, =testing_privileged_data
    ldr r0, [r0]
    ldr r0, =abt_return
    ldr r0, [r0]
    ASSERT_EQ r0, #TESTING_DATA_READ_FAULT
    mov pc, lr

.text
.type prv_test_data_write_fault, %function
prv_test_data_write_fault:
    ldr r0, =read_only_var
    str r0, [r0]
    ldr r0, =abt_return
    ldr r0, [r0]
    ASSERT_EQ r0, #TESTING_DATA_WRITE_FAULT
    mov pc, lr


#ifdef ENABLE_MEMORY_MAPPING_FROM_ABORT
.text
.type prv_test_table_walk_fault, %function
prv_test_table_walk_fault:
    push {r4, lr}
    mov r4, #1000
    loop_table_walk_fault:
        bl get_random

        // Make the number a multiple of 4, to avoid alignment fault.
        // Make sure that the address does not start with 0x70000000, because
        // it may overwrite code.
        bic r0, r0, #0b11
        bic r0, r0, #0x10000000

        ldr r1, [r0]    // Page or section translation
        mov r1, #TESTING_TABLE_WALK
        str r1, [r0]
        mov r1, #0
        ldr r1, [r0]
        ASSERT_EQ r1, #TESTING_TABLE_WALK
        subs r4, r4, #1
        bgt loop_table_walk_fault
    pop {r4, lr}
    mov pc, lr
#endif

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

    #ifdef ENABLE_NEON
    vdup.u32 d1, r1
    #endif

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
    ASSERT_EQ r0, sp

    #ifdef ENABLE_NEON
    mov r0, #55
    vmov.u32 r0, r1, d1
    ASSERT_EQ r0, #1
    #endif

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

    #ifdef ENABLE_NEON
    vdup.u32 d1, r1
    #endif

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

    #ifdef ENABLE_NEON
    vmov r0, r1, d1
    ASSERT_EQ r0, #101
    #endif

    b test_success
    b prv_testing_task2

.data
last_task_executed: .word TESTING_START
task1_stack: .word TESTING_START
task2_stack: .word TESTING_START
#endif

#ifdef ENABLE_NEON
.text
.type prv_test_neon, %function
prv_test_neon:
    push {r12, lr}
    mov r0, #11
    mov r1, #22
    vmov d0, r0, r1
    mov r2, #33
    mov r3, #44
    vmov d1, r2, r3
    vadd.u32 d0, d0, d1
    vmov r0, r1, d0
    vmov r2, r3, d1
    ASSERT_EQ r0, #44
    ASSERT_EQ r1, #66

    ldr r0, =neon_load
    vld2.u16 {d0, d1}, [r0]
    vadd.u16 d0, d0, d1
    vst1.u16 {d0}, [r0]
    ldrh r1, [r0], #2
    ASSERT_EQ r1, #0x11
    ldrh r1, [r0], #2
    ASSERT_EQ r1, #0x22
    ldrh r1, [r0], #2
    ASSERT_EQ r1, #0x33
    ldrh r1, [r0], #2
    ASSERT_EQ r1, #0x44

    bl test_neon
    pop {r12, lr}
    mov pc, lr

.data
.balign 8
neon_load:
    .hword 0x1
    .hword 0x10
    .hword 0x2
    .hword 0x20
    .hword 0x3
    .hword 0x30
    .hword 0x4
    .hword 0x40

#endif // ENABLE_NEON

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