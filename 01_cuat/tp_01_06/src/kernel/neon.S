#include "config.h"
#include "op_modes.h"

#ifdef ENABLE_NEON

/******************************************************************************
* Macros
******************************************************************************/
.macro READ_CPACR reg
    mrc p15, 0, \reg, c1, c0, 2
.endm

.macro WRITE_CPACR reg
    mcr p15, 0, \reg, c1, c0, 2
    ISB
.endm

.equ NEON_ENABLED,   1
.equ NEON_DISABLED,  0

/******************************************************************************
* Functions
******************************************************************************/
/// @brief: Initialize NEON coprocessor.
.text
.type neon_init, %function
.global neon_init
neon_init:
    READ_CPACR r0
    orr r0, r0, #0x00f00000
    WRITE_CPACR r0
    mov pc, lr

/// @brief: Enable NEON instructions.
.text
.type neon_enable, %function
.global neon_enable
neon_enable:
    mov r0, #0x40000000
    vmsr FPEXC, r0
    mov pc, lr

/// @brief: Disable NEON instructions. Calling a NEON instruction will produce
///   an Undefined instruction abort. Using "vmsr" stalls ARM execution until
///   all NEON operations are executed from the cp10 and cp11 queue.
.text
.type neon_disable, %function
.global neon_disable
neon_disable:
    mov r0, #0x0
    vmsr FPEXC, r0
    mov pc, lr

/// @brief: Returns "0" if NEON is disabled, or "1" if its enabled.
.text
.type neon_is_enabled, %function
.global neon_is_enabled
neon_is_enabled:
    vmrs r0, FPEXC
    tst r0, #0x40000000
    moveq r0, #NEON_DISABLED
    movne r0, #NEON_ENABLED
    mov pc, lr


/// @brief: Checks if NEON is enabled, and does the following:
///   - If it is enabled, this function does nothing.
///   - If it is disabled, it will enable NEON and return the value to
///   subtract from the link register in order to retry execution of the undefined
///   instruction.
/// @return (r0): Value to subtract from link register. Use "sub lr, lr, r0".
.text
.type neon_undef_handler, %function
.global neon_undef_handler
neon_undef_handler:
    push {r12, lr}
    bl neon_is_enabled
    teq r0, #NEON_ENABLED
    beq undef_neon_enabled
    undef_neon_disabled:
        bl neon_enable

        // Get FPSCR and NEON registers
        bl __scheduler_get_current_task_context_addr
        add r0, r0, #76     // table1 + asid + spsr + r0-15 = 18*4 = 76
        ldr r1, [r0], #4    // fpscr
        vmsr FPSCR, r1
        vldmia r0!, {Q0-Q7}
        vldmia r0!, {Q8-Q15}

        mrs r0, SPSR
        tst r0, #T_BIT
        moveq r0, #4    // lr - 4 for ARM to execute same instruction that caused abort
        movne r0, #2    // lr -2 for Thumb
        b neon_undef_handler_exit

    undef_neon_enabled:
        mov r0, #0

    neon_undef_handler_exit:
        pop {r12, lr}
        mov pc, lr

#endif // ENABLE_NEON
