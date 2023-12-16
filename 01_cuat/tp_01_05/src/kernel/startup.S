#include "config.h"
.include "mmu_macros.S"
#include "op_modes.h"

/// @brief: Handles all the initialization steps before executing user code.
///   This function is executed by the kernel in SYSTEM mode, right after
///   a reset.
.section .init
.global _start
.type _start, %function
_start:
    set_stack_pointers:
        msr CPSR, #IRQ_MODE|I_BIT|F_BIT // IRQ
        ldr sp, =stack_top_irq
        msr CPSR, #FIQ_MODE|I_BIT|F_BIT // FIQ
        ldr sp, =stack_top_fiq

        msr CPSR, #SVC_MODE|I_BIT|F_BIT // SVC
        ldr sp, =stack_top_svc

        msr CPSR, #ABT_MODE|I_BIT|F_BIT // ABT
        ldr sp, =stack_top_abt

        msr CPSR, #UND_MODE|I_BIT|F_BIT // UND
        ldr sp, =stack_top_und

        msr CPSR, #SYS_MODE|I_BIT|F_BIT // KERNEL
        ldr sp, =stack_top_kernel

    bl copy_kernel_sections_to_ram

    bl mmu_init

    bl prv_task_init

    #ifdef ENABLE_TESTING
        ldr r0, =testing_table1_addr
        WRITE_TTBR0 r0
        bl copy_testing_sections_to_ram
        b test_system
    #else
        cpsie aif, #SYS_MODE
        b main
    #endif

/// @brief Fill each task page tables, and copy its sections to ram. New tasks
///   should be added here, copying the code for "taskX" and replacing the "X"
///   for the task number.
///   The code is added here because the "task1" entrypoint and its stack
///   pointer are only paginated for the task1 table, so you need to first
///   change the page tables before working with them.
.text
.type prv_task_init, %function
prv_task_init:
    push {r12, lr}
    bl scheduler_init
    // Task 1
    ldr r0, =kernel_sections
    ldr r1, =kernel_sections_end
    ldr r2, =task1_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =hardware_sections
    ldr r1, =hardware_sections_end
    ldr r2, =task1_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =task1_sections
    ldr r1, =task1_sections_end
    ldr r2, =task1_table1_addr
    bl mmu_fill_page_tables

    ldr r0, =task1_table1_addr
    WRITE_TTBR0 r0
    bl copy_task1_sections_to_ram
    ldr r0, =task1
    ldr r1, =task1_stack_top
    ldr r2, =task1_table1_addr
    bl scheduler_add_task

    // Task 2
    ldr r0, =kernel_sections
    ldr r1, =kernel_sections_end
    ldr r2, =task2_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =hardware_sections
    ldr r1, =hardware_sections_end
    ldr r2, =task2_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =task2_sections
    ldr r1, =task2_sections_end
    ldr r2, =task2_table1_addr
    bl mmu_fill_page_tables

    ldr r0, =task2_table1_addr
    WRITE_TTBR0 r0
    bl copy_task2_sections_to_ram
    ldr r0, =task2
    ldr r1, =task2_stack_top
    ldr r2, =task2_table1_addr
    bl scheduler_add_task

    #ifdef ENABLE_TESTING
    // Testing task
    ldr r0, =kernel_sections
    ldr r1, =kernel_sections_end
    ldr r2, =testing_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =hardware_sections
    ldr r1, =hardware_sections_end
    ldr r2, =testing_table1_addr
    bl mmu_fill_page_tables
    ldr r0, =testing_sections
    ldr r1, =testing_sections_end
    ldr r2, =testing_table1_addr
    bl mmu_fill_page_tables
    #endif

    // Return with kernel table
    ldr r0, =kernel_table1_addr
    WRITE_TTBR0 r0
    pop {r12, lr}
    mov pc, lr

/******************************************************************************
* Stack section definition
******************************************************************************/
#define STACK_USER_SIZE         0x4000
#define STACK_IRQ_SIZE          0x200
#define STACK_FIQ_SIZE          0x200
#define STACK_SVC_SIZE          0x200
#define STACK_ABT_SIZE          0x200
#define STACK_UND_SIZE          0x200
#define STACK_KERNEL_SIZE       0x200
#define STACK_IDLE_TASK_SIZE    0x100

.section .stack, "aw", %nobits
.space STACK_IRQ_SIZE
.balign 8
stack_top_irq:

.space STACK_FIQ_SIZE
.balign 8
stack_top_fiq:

.space STACK_SVC_SIZE
.balign 8
stack_top_svc:

.space STACK_ABT_SIZE
.balign 8
stack_top_abt:

.space STACK_UND_SIZE
.balign 8
stack_top_und:

.space STACK_KERNEL_SIZE
.balign 8
stack_top_kernel:

.space STACK_IDLE_TASK_SIZE
.balign 8
.global stack_idle_task
stack_idle_task:
