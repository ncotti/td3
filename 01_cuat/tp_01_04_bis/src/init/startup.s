.include "startup_h.s"

/// @brief: Handles all the initialization steps before executing user code.
///     This function is executed by the kernel in SYSTEM mode, right after
///     a reset.
.section .init
.global startup
.type startup, %function
startup:
    // Change operation mode, disable IRQ and FIQ, and
    // set stack pointer for each mode
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

    // Copy vector table
    ldr r0, =ld_vector_table_vma
    ldr r1, =ld_vector_table_lma
    ldr r2, =ld_vector_table_size
    bl memcopy

    // Copy rest of kernel code
    ldr r0, =ld_kernel_code_vma
    ldr r1, =ld_kernel_code_lma
    ldr r2, =ld_kernel_code_size
    bl memcopy

    // Copy init data
    ldr r0, =ld_init_data_vma
    ldr r1, =ld_init_data_lma
    ldr r2, =ld_init_data_size
    bl memcopy

    bl mmu_init

    // Copy text section
    ldr r0, =ld_text_vma
    ldr r1, =ld_text_lma
    ldr r2, =ld_text_size
    bl memcopy

    // Copy data section
    ldr r0, =ld_data_vma
    ldr r1, =ld_data_lma
    ldr r2, =ld_data_size
    bl memcopy

    // Fill bss section with 0x00
    ldr r0, =ld_bss_vma
    mov r1, #0x00
    ldr r2, =ld_bss_size
    bl memfill

    msr CPSR, #SYS_MODE|I_BIT|F_BIT // For user mode, change to SYS instead
    ldr sp, =stack_top_user

    ldr r0, =_start
    b change_to_user_mode


/// @brief: This function is written in the ".text" section, so that after
///     changing to user mode, the next instruction is executable by the user.
/// @param r0 (addr): Address of the user code where to jump
.text
.type change_to_user_mode, %function
change_to_user_mode:
    cpsie aif, #USR_MODE    // Change to user mode, enable interrupts
    mov pc, r0

/******************************************************************************
* Stack section definition
******************************************************************************/
// User stack is application dependant, and can be moved in memory
.section .stack, "aw", %nobits
.space STACK_USER_SIZE
.balign 8   // aligned to a multiple of 8
stack_top_user:

// Kernel stack is identity mapped in memory, and is always known where it is.
.section .kernel_stack, "aw", %nobits
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
