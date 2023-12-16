/// @file app0_sections.s
/// This file holds all sections defined by the application 0.
/// All extra applications beside this one must be defined in a similar file.

/******************************************************************************
* Headers
******************************************************************************/
.extern ld_text_vma, ld_text_size
.extern ld_data_vma, ld_data_size
.extern ld_bss_vma, ld_bss_size
.extern ld_stack_vma, ld_stack_size
.include "mmu_h.s"

/******************************************************************************
* App sections
******************************************************************************/
.section .rodata
.global app0_sections
.global app0_sections_end
app0_sections:
// Code
.word ld_text_vma
.word ld_text_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_X

// Data
.word ld_data_vma
.word ld_data_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Bss
.word ld_bss_vma
.word ld_bss_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Stack
.word ld_stack_vma
.word ld_stack_size
.word ld_stack_vma
.byte DOMAIN_STACK
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX
app0_sections_end:

/******************************************************************************
* Page table section
******************************************************************************/
.section .page_table, "aw", %nobits
.global app0_table1_addr
.balign 0x4000  // Align to 16K
app0_table1_addr:   .space TABLE1_SIZE
app0_table2_addr:   .space TABLE2_SIZE * TABLE2_QTTY
