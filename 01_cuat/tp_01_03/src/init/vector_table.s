.extern str_inv, str_mem, str_svc
.extern C_IRQ_Handler
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
.text
UND_handler:
    ldr r10, =str_inv
    ldr r10, [r10]
    movs pc, lr

/******************************************************************************
*   Software interrupt handler (Supervisor Call)
******************************************************************************/
SVC_handler:
    ldr r10, =str_svc
    ldr r10, [r10]
    //ldrb r0, [lr, #-4]  // Copy content of SVC syscall_number to r0
    movs pc, lr

/******************************************************************************
*   Prefetch error handler
******************************************************************************/
PREF_handler:
    ldr r10, =str_mem
    ldr r10, [r10]
    subs pc, lr, #4

/******************************************************************************
*   Data abort handler
******************************************************************************/
ABT_handler:
    ldr r10, =str_mem
    ldr r10, [r10]
    subs pc, lr, #8

/******************************************************************************
*   Interrupt handler (IRQ)
******************************************************************************/
IRQ_handler:
    push {lr}
    bl C_IRQ_Handler
    pop {lr}
    subs pc, lr, #4

/******************************************************************************
*   Fast Interrupt handler (FIQ)
******************************************************************************/
FIQ_handler:
    subs pc, lr, #4
