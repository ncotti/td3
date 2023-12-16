/*-----------------------------------------------------------------------------
*   @Brief:
*       This function handles all the initialization steps before executing
*       user code, which include:
*       - Copy LMAs into VMAs for sections .text, .data, .vector_table, etc.
*       - Initialize the stack pointer of all operation modes.
*       - Change into user mode, activate interruptions.
*
*   @Args:
*       None
*
*   @Return:
*       Void
-----------------------------------------------------------------------------*/
.extern ld_vector_table_lma, ld_vector_table_vma, ld_vector_table_size
.extern ld_text_lma, ld_text_vma, ld_text_size
.extern ld_data_origin, ld_data_vma, ld_data_size
.extern ld_bss_vma, ld_bss_size, ld_bss_pattern
.extern memcopy, memfill
.extern ld_user_stack_top, ld_irq_stack_top, ld_fiq_stack_top
.extern ld_svc_stack_top, ld_abt_stack_top, ld_und_stack_top

.include "op_modes.s"

.global boot
.section .init
boot:
    // Change operation mode, disable IRQ and FIQ, set stack pointer for each mode
    msr CPSR, #IRQ_MODE|I_BIT|F_BIT // IRQ
    ldr sp, =ld_irq_stack_top

    msr CPSR, #FIQ_MODE|I_BIT|F_BIT // FIQ
    ldr sp, =ld_fiq_stack_top

    msr CPSR, #SVC_MODE|I_BIT|F_BIT // SVC
    ldr sp, =ld_svc_stack_top

    msr CPSR, #ABT_MODE|I_BIT|F_BIT // ABT
    ldr sp, =ld_abt_stack_top

    msr CPSR, #UND_MODE|I_BIT|F_BIT // UND
    ldr sp, =ld_und_stack_top

    msr CPSR, #SYS_MODE|I_BIT|F_BIT // For user mode, change to SYS instead
    ldr sp, =ld_user_stack_top

    // Copy vector table
    ldr r0, =ld_vector_table_vma
    ldr r1, =ld_vector_table_lma
    ldr r2, =ld_vector_table_size
    bl memcopy

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
    ldr r1, =ld_bss_pattern
    ldr r2, =ld_bss_size
    bl memfill

    cpsie aif, #USR_MODE    // Change to user mode, enable interrupts
    ldr pc, =_start     // Go to program start
