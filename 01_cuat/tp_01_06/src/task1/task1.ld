/* This file defines all sections for the task1 */

/******************************************************************************
*   Memory sections
******************************************************************************/
.task1_text : ALIGN(4K) {
    *task1/*(.text)
} >task1_ram AT>rom
PROVIDE(ld_task1_text_lma = LOADADDR(.task1_text));
PROVIDE(ld_task1_text_vma = ADDR(.task1_text));
PROVIDE(ld_task1_text_size = SIZEOF(.task1_text));

.task1_data : ALIGN(4K) {
    *task1/*(.data)
} >task1_ram AT>rom
PROVIDE(ld_task1_data_lma = LOADADDR(.task1_data));
PROVIDE(ld_task1_data_vma = ADDR(.task1_data));
PROVIDE(ld_task1_data_size = SIZEOF(.task1_data));

.task1_rodata : ALIGN(4K) {
    *task1/*(.rodata)
} >task1_ram AT>rom
PROVIDE(ld_task1_rodata_lma = LOADADDR(.task1_rodata));
PROVIDE(ld_task1_rodata_vma = ADDR(.task1_rodata));
PROVIDE(ld_task1_rodata_size = SIZEOF(.task1_rodata));

.task1_stack (NOLOAD) : ALIGN(4K) {
    *task1/*(.stack)
} >task1_ram
PROVIDE(ld_task1_stack_vma = ADDR(.task1_stack));
PROVIDE(ld_task1_stack_size = SIZEOF(.task1_stack));

.task1_bss (NOLOAD) : ALIGN(4K) {
    *task1/*(.bss)
    *task1/*(COMMON)    /**/
} >task1_ram
PROVIDE(ld_task1_bss_vma = ADDR(.task1_bss));
PROVIDE(ld_task1_bss_size = SIZEOF(.task1_bss));

.task1_reading_area (NOLOAD) : ALIGN(4K) {
    *task1/*(.reading_area)
} >task1_ram
PROVIDE(ld_task1_reading_area_vma = ADDR(.task1_reading_area));
PROVIDE(ld_task1_reading_area_size = SIZEOF(.task1_reading_area));
