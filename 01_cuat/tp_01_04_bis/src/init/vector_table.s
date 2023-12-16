/******************************************************************************
* Headers
******************************************************************************/
.extern C_IRQ_Handler
.extern mmu_prefetch_handler, mmu_abort_handler
.extern data_abort_handler, pre_abort_handler
.include "mmu_h.s"

/******************************************************************************
* Instructions to be loaded in the vector table
******************************************************************************/
.section .vector_table, "ax", %progbits
_vector_table:
    ldr pc, =RESET_handler
    ldr pc, =UND_handler
    ldr pc, =SVC_handler
    ldr pc, =PREF_handler
    ldr pc, =ABT_handler
    ldr pc, =0x00
    ldr pc, =IRQ_handler
    ldr pc, =FIQ_handler

/******************************************************************************
*   Reset handler
******************************************************************************/
.global RESET_handler
.section .init
RESET_handler:
    b startup             // Intialize memory sections

/******************************************************************************
*   Undefined instruction handler
******************************************************************************/
.section .kernel_code, "ax", %progbits
.type UND_handler, %function
UND_handler:
    push {r10}
    ldr r10, =str_inv
    ldr r10, [r10]
    pop {r10}
    movs pc, lr

/******************************************************************************
*   Software interrupt handler (Supervisor Call)
******************************************************************************/
.type SVC_handler, %function
SVC_handler:
    push {r0, r10}
    ldr r10, =str_svc
    ldr r10, [r10]
    ldrb r0, [lr, #-4]  // Copy content of SVC syscall_number to r0
    pop {r0, r10}
    movs pc, lr

/******************************************************************************
*   Prefetch error handler
******************************************************************************/
.type PREF_handler, %function
PREF_handler:
    push {r0-r3, r10, lr}
    ldr r10, =str_mem
    ldr r10, [r10]
    READ_IFSR r0, r2
    READ_IFAR r1
    bl pre_abort_handler
    pop {r10, lr}
    teq r0, #1
    subeqs pc, lr, #0   // Return to next instruction to be executed
    subs pc, lr, #4     // Return to instruction that caused the abort

/******************************************************************************
*   Data abort handler
******************************************************************************/
.type ABT_handler, %function
ABT_handler:
    push {r0-r3, r10, lr}
    ldr r10, =str_mem
    ldr r10, [r10]
    READ_DFSR r0, r2, r3
    READ_DFAR r1
    bl data_abort_handler
    teq r0, #1
    pop {r0-r3, r10, lr}
    subeqs pc, lr, #4   // Return to next instruction to be executed
    subs pc, lr, #8     // Return to instruction that caused the abort

/******************************************************************************
*   Interrupt handler (IRQ)
******************************************************************************/
.type IRQ_handler, %function
IRQ_handler:
    push {r0-r3, r12, lr}
    bl C_IRQ_Handler
    pop {r0-r3, r12, lr}
    subs pc, lr, #4

/******************************************************************************
*   Fast Interrupt handler (FIQ)
******************************************************************************/
.type FIQ_handler, %function
FIQ_handler:
    subs pc, lr, #4

/******************************************************************************
*   Data
******************************************************************************/
.section .init_data
str_inv: .string "INV"
str_mem: .string "MEM"
str_svc: .string "SVC"
