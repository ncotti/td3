/// @file task1_sections.S
/// This file holds all the sections for the task1. To add extra tasks,
/// copy this file and change "task1" with the name of the corresponding task.
#include "mmu.h"

/******************************************************************************
* Sections
******************************************************************************/
.section .rodata
.global task1_sections
.global task1_sections_end
task1_sections:
// Code
.word ld_task1_text_vma                 // Initial VA
.word ld_task1_text_size                // Size of the section
.word 0x70F50000                        // Physical Address (can be NO_PA if not needed)
.byte DOMAIN_RAM_FREE                   // Domain
.byte AP_RW_R                           // Access permissions
.byte MEM_WRITE_BACK_WRITE_ALLOCATE     // Memory type
.byte NG_S_X                            // Global, shareable, executable

// Data
.word ld_task1_data_vma
.word ld_task1_data_size
.word 0x70F51000
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Rodata
.word ld_task1_rodata_vma
.word ld_task1_rodata_size
.word 0x70F54000
.byte DOMAIN_RAM_FREE
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Stack
.word ld_task1_stack_vma
.word ld_task1_stack_size
.word 0x70F52000
.byte DOMAIN_STACK
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Bss
.word ld_task1_bss_vma
.word ld_task1_bss_size
.word 0x70F53000
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Reading area
.word ld_task1_reading_area_vma
.word ld_task1_reading_area_size
.word 0x70A10000
.byte DOMAIN_RAM_FREE
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX
task1_sections_end:

/******************************************************************************
* Functions
******************************************************************************/
/// @brief: This function copies all sections from the task1 into RAM:
///   * ".text", ".data" and ".rodata" get copied.
///   * ".bss" gets filled with "0".
.text
.type copy_task1_sections_to_ram, %function
.global copy_task1_sections_to_ram
copy_task1_sections_to_ram:
    push {r12, lr}

    ldr r0, =ld_task1_text_vma
    ldr r1, =ld_task1_text_lma
    ldr r2, =ld_task1_text_size
    bl __memcopy

    ldr r0, =ld_task1_data_vma
    ldr r1, =ld_task1_data_lma
    ldr r2, =ld_task1_data_size
    bl __memcopy

    ldr r0, =ld_task1_rodata_vma
    ldr r1, =ld_task1_rodata_lma
    ldr r2, =ld_task1_rodata_size
    bl __memcopy

    ldr r0, =ld_task1_bss_vma
    mov r1, #0x00
    ldr r2, =ld_task1_bss_size
    bl __memfill

    pop {r12, lr}
    mov pc, lr

/******************************************************************************
* Page table section
******************************************************************************/
.section .page_table1, "aw", %nobits
.global task1_table1_addr
.balign 0x4000  // Align to 16K
task1_table1_addr:   .space TABLE1_SIZE

.section .page_table2, "aw", %nobits
task1_table2_addr:   .space TABLE2_SIZE * TABLE2_QTTY
