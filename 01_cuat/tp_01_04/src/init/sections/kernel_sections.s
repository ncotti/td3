/// @file kernel_sections.s
/// This file holds all sections defined for the kernel

/******************************************************************************
* Headers
******************************************************************************/
.extern ld_init_vma, ld_init_size
.extern ld_vector_table_vma, ld_vector_table_size
.extern ld_text_lma, ld_data_lma
.extern ld_page_table_vma, ld_page_table_size
.extern ld_kernel_stack_vma, ld_kernel_stack_size
.extern ld_rodata_vma, ld_rodata_size
.extern ld_init_data_vma, ld_init_data_size
.extern ld_kernel_code_vma, ld_kernel_code_lma, ld_kernel_code_size

.include "mmu_h.s"

/******************************************************************************
* Kernel sections
******************************************************************************/
.section .rodata
.global kernel_sections
.global kernel_sections_end
kernel_sections:
// Code
.word ld_init_vma                       // Initial VA
.word ld_init_size                      // Size of the section
.word ld_init_vma                       // Fixed PA (can be NO_PA if not needed)
.byte DOMAIN_KERNEL                     // Domain
.byte AP_R_N                            // Access permissions
.byte MEM_WRITE_BACK_WRITE_ALLOCATE     // Memory type
.byte G_S_X                             // Global, shareable, executable

// Physical space occupied by the page tables
.word ld_page_table_vma
.word ld_page_table_size
.word ld_page_table_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_THROUGH_NO_WRITE_ALLOCATE
.byte G_NS_NX

// Ram space used by the kernel
.word ld_init_data_vma
.word ld_init_data_size
.word ld_init_data_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_NS_NX

// Rodata (Mostly these files with the program descriptions)
.word ld_rodata_vma
.word ld_rodata_size
.word ld_rodata_vma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Vector table
.word ld_vector_table_vma
.word ld_vector_table_size
.word ld_vector_table_vma
.byte DOMAIN_KERNEL
.byte AP_RW_R
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_X

// Stack for kernel
.word ld_kernel_stack_vma
.word ld_kernel_stack_size
.word ld_kernel_stack_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Kernel code executed after the MMU
.word ld_kernel_code_vma
.word ld_kernel_code_size
.word ld_kernel_code_vma
.byte DOMAIN_KERNEL
.byte AP_RW_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_X

// App code which must be moved from the ROM to the RAM
.word ld_text_lma
.word ld_text_size
.word ld_text_lma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// App data which must be moved from the ROM to the RAM
.word ld_data_lma
.word ld_data_size
.word ld_data_lma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX

// Kernel code which must be moved from the ROM to the RAM
.word ld_kernel_code_lma
.word ld_kernel_code_size
.word ld_kernel_code_lma
.byte DOMAIN_KERNEL
.byte AP_R_N
.byte MEM_WRITE_BACK_WRITE_ALLOCATE
.byte G_S_NX
kernel_sections_end:


