/// @file task2_sections.S
/// This file holds all the sections for the task2. To add extra tasks,
/// copy this file and change "task2" with the name of the corresponding task.
#include "mmu.h"

/******************************************************************************
* Sections
******************************************************************************/
.section .rodata
.global task2_sections
.global task2_sections_end
task2_sections:
// Code
.word ld_task2_text_vma                 // Initial VA
.word ld_task2_text_size                // Size of the section
.word 0x70F40000                        // Physical Address (can be NO_PA if not needed)
.byte DOMAIN_RAM_FREE                   // Domain
.byte AP_RW_R                           // Access permissions
.byte MEM_WRITE_BACK_WRITE_ALLOCATE     // Memory type
.byte NG_S_X                            // Global, shareable, executable

// Data
.word ld_task2_data_vma
.word ld_task2_data_size
.word 0x70F42000
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Rodata
.word ld_task2_rodata_vma
.word ld_task2_rodata_size
.word 0x70F44000
.byte DOMAIN_RAM_FREE
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Stack
.word ld_task2_stack_vma
.word ld_task2_stack_size
.word 0x70F45000
.byte DOMAIN_STACK
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Bss
.word ld_task2_bss_vma
.word ld_task2_bss_size
.word 0x70F43000
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX

// Reading area
.word ld_task2_reading_area_vma
.word ld_task2_reading_area_size
.word 0x70A00000
.byte DOMAIN_RAM_FREE
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte NG_S_NX
task2_sections_end:

/******************************************************************************
* Functions
******************************************************************************/
/// @brief: This function copies all sections from the task2 into RAM:
///   * ".text", ".data" and ".rodata" get copied.
///   * ".bss" gets filled with "0".
.text
.type copy_task2_sections_to_ram, %function
.global copy_task2_sections_to_ram
copy_task2_sections_to_ram:
    push {r12, lr}

    ldr r0, =ld_task2_text_vma
    ldr r1, =ld_task2_text_lma
    ldr r2, =ld_task2_text_size
    bl memcopy

    ldr r0, =ld_task2_data_vma
    ldr r1, =ld_task2_data_lma
    ldr r2, =ld_task2_data_size
    bl memcopy

    ldr r0, =ld_task2_rodata_vma
    ldr r1, =ld_task2_rodata_lma
    ldr r2, =ld_task2_rodata_size
    bl memcopy

    ldr r0, =ld_task2_bss_vma
    mov r1, #0x00
    ldr r2, =ld_task2_bss_size
    bl memfill

    pop {r12, lr}
    mov pc, lr

/******************************************************************************
* Page table section
******************************************************************************/
.section .page_table1, "aw", %nobits
.global task2_table1_addr
.balign 0x4000  // Align to 16K
task2_table1_addr:   .space TABLE1_SIZE

.section .page_table2, "aw", %nobits
task2_table2_addr:   .space TABLE2_SIZE * TABLE2_QTTY
