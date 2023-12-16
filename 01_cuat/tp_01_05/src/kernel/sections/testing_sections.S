/// @file testing_sections.S
/// This file is only compiled when testing the system. Contains all sections
/// used for testing purposes.
#include "config.h"

#ifdef ENABLE_TESTING
#include "mmu.h"
/******************************************************************************
* Sections
******************************************************************************/
.section .rodata
.global testing_sections
.global testing_sections_end
testing_sections:
// Code
.word ld_testing_text_vma               // Initial VA
.word ld_testing_text_size              // Size of the section
.word NO_PA                             // Physical Address (can be NO_PA if not needed)
.byte DOMAIN_RAM_FREE                   // Domain
.byte AP_RW_R                           // Access permissions
.byte MEM_WRITE_BACK_WRITE_ALLOCATE     // Memory type
.byte NG_S_X                            // Global, shareable, executable

// Data
.word ld_testing_data_vma
.word ld_testing_data_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Rodata
.word ld_testing_rodata_vma
.word ld_testing_rodata_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Stack
.word ld_testing_stack_vma
.word ld_testing_stack_size
.word NO_PA
.byte DOMAIN_STACK
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Bss
.word ld_testing_bss_vma
.word ld_testing_bss_size
.word NO_PA
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX
testing_sections_end:

/******************************************************************************
* Functions
******************************************************************************/
/// @brief: This function copies all sections from the testing into RAM:
///   * ".text", ".data" and ".rodata" get copied.
///   * ".bss" gets filled with "0".
.text
.type copy_testing_sections_to_ram, %function
.global copy_testing_sections_to_ram
copy_testing_sections_to_ram:
    push {r12, lr}

    ldr r0, =ld_testing_text_vma
    ldr r1, =ld_testing_text_lma
    ldr r2, =ld_testing_text_size
    bl memcopy

    ldr r0, =ld_testing_data_vma
    ldr r1, =ld_testing_data_lma
    ldr r2, =ld_testing_data_size
    bl memcopy

    ldr r0, =ld_testing_rodata_vma
    ldr r1, =ld_testing_rodata_lma
    ldr r2, =ld_testing_rodata_size
    bl memcopy

    ldr r0, =ld_testing_bss_vma
    mov r1, #0x00
    ldr r2, =ld_testing_bss_size
    bl memfill

    pop {r12, lr}
    mov pc, lr

/******************************************************************************
* Page table section
******************************************************************************/
.section .page_table1, "aw", %nobits
.global testing_table1_addr
.balign 0x4000  // Align to 16K
testing_table1_addr:   .space TABLE1_SIZE

.section .page_table2, "aw", %nobits
testing_table2_addr:   .space TABLE2_SIZE * TABLE2_QTTY

#endif // ENABLE_TESTING
