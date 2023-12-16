#ifndef MMU_MACROS_H
#define MMU_MACROS_H
/******************************************************************************
* Macros for accessing the coprocessor 15 (p15)
******************************************************************************/
.macro WRITE_ASID_CONSTANT value
    // ASID is the first 8 bits of the CONTEXTIDR
    push {r0}
    MRC p15, 0, r0, c13, c0, 1
    bic r0, #0xFF
    orr r0, r0, #\value
    MCR p15, 0, r0, c13, c0, 1
    pop {r0}
.endm

.macro WRITE_ASID_REG asid_reg buffer_reg
    // ASID is the first 8 bits of the CONTEXTIDR
    MRC p15, 0, \buffer_reg, c13, c0, 1
    bic \buffer_reg, #0xFF
    orr \buffer_reg, \buffer_reg, \asid_reg
    MCR p15, 0, \buffer_reg, c13, c0, 1
.endm

.macro READ_TTBR0 reg
    MRC p15, 0, \reg, c2, c0, 0
.endm

.macro WRITE_TTBR0 reg
    ISB
    MCR p15, 0, \reg, c2, c0, 0
    ISB
.endm

.macro WRITE_TTBR0_WITH_ASID ttbr0_reg, asid_reg
    WRITE_ASID_CONSTANT 0
    WRITE_TTBR0 \ttbr0_reg
    WRITE_ASID_REG \asid_reg, \ttbr0_reg
.endm

.macro READ_TTBR1 reg
    MRC p15, 0, \reg, c2, c0, 1
.endm

.macro WRITE_TTBR1 reg
    ISB
    MCR p15, 0, \reg, c2, c0, 1
    ISB
.endm

.macro WRITE_TTBR1_WITH_ASID ttbr1_reg, asid_reg
    WRITE_ASID_CONSTANT 0
    WRITE_TTBR1 \ttbr1_reg
    WRITE_ASID \asid_reg, \ttbr1_reg
.endm

.macro READ_TTBCR reg
    MRC p15, 0, \reg, c2, c0, 2
.endm

.macro WRITE_TTBCR reg
    MCR p15, 0, \reg, c2, c0, 2
.endm

.macro READ_SCTRL reg
    MRC p15, 0, \reg, c1, c0, 0
.endm

.macro WRITE_SCTRL reg
    MCR p15, 0, \reg, c1, c0, 0
.endm

.macro READ_DACR reg
    MRC p15, 0, \reg, c3, c0, 0
.endm

.macro WRITE_DACR reg
    MCR p15, 0, \reg, c3, c0, 0
.endm

.macro READ_DFSR fault, wnr, aux
    MRC p15, 0, \fault, c5, c0, 0
    mov \aux, \fault
    mov \wnr, \fault

    // Get fault number (bits 10, [3:0])
    and \fault, \fault, #0xF
    lsr \aux, \aux, #10
    and \aux, \aux, #1
    orr \fault, \fault, \aux, lsl #4

    // Get WnR (write or read fault) in [11]
    lsr \wnr, \wnr, #11
    and \wnr, \wnr, #1
.endm

.macro READ_DFAR reg
    MRC p15, 0, \reg, c6, c0, 0
.endm

.macro READ_IFSR fault, aux
    MRC p15, 0, \fault, c5, c0, 1
    mov \aux, \fault

    // Get fault number (bits 10, [3:0])
    and \fault, \fault, #0xF
    lsr \aux, \aux, #10
    and \aux, \aux, #1
    orr \fault, \fault, \aux, lsl #4
.endm

.macro READ_IFAR reg
    MRC p15, 0, \reg, c6, c0, 2
.endm

/******************************************************************************
* Macros for accessing bit regions
******************************************************************************/
.macro GET_DOMAIN_FROM_PTE1 domain pte1
    mov \domain, \pte1
    lsr \domain, \domain, #5
    and \domain, \domain, #0xF
.endm

.macro GET_PTE1_INDEX_FROM_VMA pte1_index vma
    lsr \pte1_index, \vma, #20 // first 12 bits
.endm

.macro GET_PTE2_INDEX_FROM_VMA pte2_index vma
    lsr \pte2_index, \vma, #12      // pte2 index in bits [19:12]
    bic \pte2_index, #0xFFFFFF00    // mask 8 LSB.
.endm

.macro GET_TABLE2_ADDR_FROM_PTE1 table2_addr pte1
    mov \table2_addr, \pte1
    bic \table2_addr, \table2_addr, #0xFF     // table2 addr in first 22 bits, put on "0" 10 LSB.
    bic \table2_addr, \table2_addr, #0x300    // Done in separate instructions to be able to use constants.
.endm

#endif // MMU_MACROS_H
