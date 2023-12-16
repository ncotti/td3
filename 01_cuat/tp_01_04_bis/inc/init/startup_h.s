/******************************************************************************
* Includes
******************************************************************************/
// Linker variables
.extern ld_kernel_code_lma, ld_kernel_code_vma, ld_kernel_code_size
.extern ld_vector_table_lma, ld_vector_table_vma, ld_vector_table_size
.extern ld_init_data_lma, ld_init_data_vma, ld_init_data_size
.extern ld_text_lma, ld_text_vma, ld_text_size
.extern ld_data_origin, ld_data_vma, ld_data_size
.extern ld_bss_vma, ld_bss_size

// Functions
.extern memcopy, memfill
.extern _start

/******************************************************************************
* Operation Modes
******************************************************************************/
.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ SVC_MODE, 0x13
.equ ABT_MODE, 0x17
.equ UND_MODE, 0x1B
.equ SYS_MODE, 0x1F

.equ I_BIT, 0x80    // Disable IRQ
.equ F_BIT, 0x40    // Disable FIQ

/******************************************************************************
* Stack sizes for each mode
******************************************************************************/
.equ STACK_USER_SIZE,   0x4000
.equ STACK_IRQ_SIZE,    0x1000
.equ STACK_FIQ_SIZE,    0x1000
.equ STACK_SVC_SIZE,    0x1000
.equ STACK_ABT_SIZE,    0x1000
.equ STACK_UND_SIZE,    0x1000
.equ STACK_KERNEL_SIZE, 0x1000
