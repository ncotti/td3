/* This file defines all sections for the testing */

/******************************************************************************
*   Memory sections
******************************************************************************/
.testing_text : ALIGN(4K) {
    *testing/*(.text)
} >fixed_ram AT>rom
PROVIDE(ld_testing_text_lma = LOADADDR(.testing_text));
PROVIDE(ld_testing_text_vma = ADDR(.testing_text));
PROVIDE(ld_testing_text_size = SIZEOF(.testing_text));

.testing_data : ALIGN(4K) {
    *testing/*(.data)
} >fixed_ram AT>rom
PROVIDE(ld_testing_data_lma = LOADADDR(.testing_data));
PROVIDE(ld_testing_data_vma = ADDR(.testing_data));
PROVIDE(ld_testing_data_size = SIZEOF(.testing_data));

.testing_rodata : ALIGN(4K) {
    *testing/*(.rodata)
} >fixed_ram AT>rom
PROVIDE(ld_testing_rodata_lma = LOADADDR(.testing_rodata));
PROVIDE(ld_testing_rodata_vma = ADDR(.testing_rodata));
PROVIDE(ld_testing_rodata_size = SIZEOF(.testing_rodata));

.testing_stack (NOLOAD) : ALIGN(4K) {
    *testing/*(.stack)
} >fixed_ram
PROVIDE(ld_testing_stack_vma = ADDR(.testing_stack));
PROVIDE(ld_testing_stack_size = SIZEOF(.testing_stack));

.testing_bss (NOLOAD) : ALIGN(4K) {
    *testing/*(.bss)
    *testing/*(COMMON)    /**/
} >fixed_ram
PROVIDE(ld_testing_bss_vma = ADDR(.testing_bss));
PROVIDE(ld_testing_bss_size = SIZEOF(.testing_bss));
