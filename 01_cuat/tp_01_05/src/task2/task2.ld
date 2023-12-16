/* This file defines all sections for the task2 */

/******************************************************************************
*   Memory sections
******************************************************************************/
.task2_text : ALIGN(4K) {
    *task2/*(.text)
} >fixed_ram AT>rom
PROVIDE(ld_task2_text_lma = LOADADDR(.task2_text));
PROVIDE(ld_task2_text_vma = ADDR(.task2_text));
PROVIDE(ld_task2_text_size = SIZEOF(.task2_text));

.task2_data : ALIGN(4K) {
    *task2/*(.data)
} >fixed_ram AT>rom
PROVIDE(ld_task2_data_lma = LOADADDR(.task2_data));
PROVIDE(ld_task2_data_vma = ADDR(.task2_data));
PROVIDE(ld_task2_data_size = SIZEOF(.task2_data));

.task2_rodata : ALIGN(4K) {
    *task2/*(.rodata)
} >fixed_ram AT>rom
PROVIDE(ld_task2_rodata_lma = LOADADDR(.task2_rodata));
PROVIDE(ld_task2_rodata_vma = ADDR(.task2_rodata));
PROVIDE(ld_task2_rodata_size = SIZEOF(.task2_rodata));

.task2_stack (NOLOAD) : ALIGN(4K) {
    *task2/*(.stack)
} >fixed_ram
PROVIDE(ld_task2_stack_vma = ADDR(.task2_stack));
PROVIDE(ld_task2_stack_size = SIZEOF(.task2_stack));

.task2_bss (NOLOAD) : ALIGN(4K) {
    *task2/*(.bss)
    *task2/*(COMMON)    /**/
} >fixed_ram
PROVIDE(ld_task2_bss_vma = ADDR(.task2_bss));
PROVIDE(ld_task2_bss_size = SIZEOF(.task2_bss));

.task2_reading_area (NOLOAD) : ALIGN(4K) {
    *task2/*(.reading_area)
} >fixed_ram
PROVIDE(ld_task2_reading_area_vma = ADDR(.task2_reading_area));
PROVIDE(ld_task2_reading_area_size = SIZEOF(.task2_reading_area));
