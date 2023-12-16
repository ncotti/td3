/// @file kernel_sections.s
/// This file holds all sections defined for the kernel.
/// All sections in this file must be identity mapped
#include "mmu.h"

/******************************************************************************
* Sections
******************************************************************************/
.section .rodata
.global kernel_sections
.global kernel_sections_end
kernel_sections:
// Executable code in ROM
.word ld_init_vma                       // Initial VA
.word ld_init_size                      // Size of the section
.word ld_init_vma                       // Physical Address (can be NO_PA if not needed)
.byte DOMAIN_KERNEL                     // Domain
.byte AP_R_N                            // Access permissions
.byte MEM_WRITE_BACK_WRITE_ALLOCATE     // Memory type
.byte G_S_X                             // Global, shareable, executable

// Vector table
.word ld_vector_table_vma
.word ld_vector_table_size
.word ld_vector_table_vma
.byte DOMAIN_KERNEL
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_X

// Non executable ROM (excludes ".init" section).
// Its contents are copied to the RAM by memcopy.
.word ld_not_executable_rom_vma
.word ld_not_executable_rom_size
.word ld_not_executable_rom_vma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Code
.word ld_kernel_text_vma
.word ld_kernel_text_size
.word ld_kernel_text_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_X

// Data
.word ld_kernel_data_vma
.word ld_kernel_data_size
.word ld_kernel_data_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Rodata
.word ld_kernel_rodata_vma
.word ld_kernel_rodata_size
.word ld_kernel_rodata_vma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Stack
.word ld_kernel_stack_vma
.word ld_kernel_stack_size
.word ld_kernel_stack_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Bss
.word ld_kernel_bss_vma
.word ld_kernel_bss_size
.word ld_kernel_bss_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Public data
.word ld_kernel_public_data_vma
.word ld_kernel_public_data_size
.word ld_kernel_public_data_vma
.byte DOMAIN_KERNEL
.byte AP_RW_RW
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Syscall
.word ld_kernel_syscall_vma
.word ld_kernel_syscall_size
.word ld_kernel_syscall_vma
.byte DOMAIN_KERNEL
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_X
kernel_sections_end:

/******************************************************************************
* Functions
******************************************************************************/
/// @brief: This function copies all sections from the kernel into RAM:
///   * ".text", ".data" and ".rodata" get copied.
///   * ".bss" gets filled with "0".
.section .init
.type copy_kernel_sections_to_ram, %function
.global copy_kernel_sections_to_ram
copy_kernel_sections_to_ram:
    push {r12, lr}

    ldr r0, =ld_vector_table_vma
    ldr r1, =ld_vector_table_lma
    ldr r2, =ld_vector_table_size
    bl __memcopy

    ldr r0, =ld_kernel_text_vma
    ldr r1, =ld_kernel_text_lma
    ldr r2, =ld_kernel_text_size
    bl __memcopy

    ldr r0, =ld_kernel_data_vma
    ldr r1, =ld_kernel_data_lma
    ldr r2, =ld_kernel_data_size
    bl __memcopy

    ldr r0, =ld_kernel_rodata_vma
    ldr r1, =ld_kernel_rodata_lma
    ldr r2, =ld_kernel_rodata_size
    bl __memcopy

    ldr r0, =ld_kernel_public_data_vma
    ldr r1, =ld_kernel_public_data_lma
    ldr r2, =ld_kernel_public_data_size
    bl __memcopy

    ldr r0, =ld_kernel_syscall_vma
    ldr r1, =ld_kernel_syscall_lma
    ldr r2, =ld_kernel_syscall_size
    bl __memcopy

    ldr r0, =ld_kernel_bss_vma
    mov r1, #0x00
    ldr r2, =ld_kernel_bss_size
    bl __memfill

    pop {r12, lr}
    mov pc, lr

/******************************************************************************
* Page table section
******************************************************************************/
.section .page_table1, "aw", %nobits
.global kernel_table1_addr
.balign 0x4000  // Align to 16K
kernel_table1_addr:   .space TABLE1_SIZE

.section .page_table2, "aw", %nobits
kernel_table2_addr:   .space TABLE2_SIZE * TABLE2_QTTY
