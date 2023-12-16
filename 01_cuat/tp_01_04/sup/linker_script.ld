/******************************************************************************
*   Output format
******************************************************************************/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(RESET_handler)

/******************************************************************************
*   Memory regions' origins and lengths
******************************************************************************/
ld_rom_origin           = 0x70010000;
ld_ram_origin           = 0x70500000;
ld_ram_kernel_origin    = 0x70200000;
ld_vector_table_origin  = 0x00000000;

ld_rom_length           = 0x10000;
ld_ram_length           = 0x200000;
ld_ram_kernel_length    = 0x200000;

/******************************************************************************
*   Memory sections
******************************************************************************/
MEMORY {
    rom         (rx) :  ORIGIN = ld_rom_origin,         LENGTH = ld_rom_length
    ram_kernel  (wa) :  ORIGIN = ld_ram_kernel_origin   LENGTH = ld_ram_kernel_length
    ram         (wa) :  ORIGIN = ld_ram_origin,         LENGTH = ld_ram_length
}

/******************************************************************************
*   Section definitions
******************************************************************************/
SECTIONS {
    /* Init section has all the boot code, before changing to user mode */
    .init : AT(ld_rom_origin) ALIGN(4K) {
        *vector_table*(.init)  /* Reset handler */
        *(.init)
    } >rom
    PROVIDE(ld_init_lma = LOADADDR(.init));
    PROVIDE(ld_init_vma = ADDR(.init));
    PROVIDE(ld_init_size = SIZEOF(.init));

    /* The vector table has its VMA at 0x00 */
    .vector_table ld_vector_table_origin : ALIGN(4K) {
        *(.vector_table)
    } AT>rom
    PROVIDE(ld_vector_table_lma = LOADADDR(.vector_table));
    PROVIDE(ld_vector_table_vma = ADDR(.vector_table));
    PROVIDE(ld_vector_table_size = SIZEOF(.vector_table));

    /* Stack space needed by the kernel*/
    .kernel_stack (NOLOAD) : ALIGN(4K) {
        *(.kernel_stack)
    } >ram_kernel
    PROVIDE(ld_kernel_stack_vma = ADDR(.kernel_stack));
    PROVIDE(ld_kernel_stack_size = SIZEOF(.kernel_stack));

    /* Variables needed by the kernel */
    .init_data : ALIGN(4K) {
        *(.init_data)
    } >ram_kernel AT>rom
    PROVIDE(ld_init_data_lma = LOADADDR(.init_data));
    PROVIDE(ld_init_data_vma = ADDR(.init_data));
    PROVIDE(ld_init_data_size = SIZEOF(.init_data));

    /* Read only variables */
    .rodata : ALIGN(4K) {
        *(.rodata)
    } >rom AT>rom
    PROVIDE(ld_rodata_lma = LOADADDR(.rodata));
    PROVIDE(ld_rodata_vma = ADDR(.rodata));
    PROVIDE(ld_rodata_size = SIZEOF(.rodata));

    /* Exception handlers and kernel code executed after the mmu */
    .kernel_code : ALIGN(4K) {
        *(.kernel_code)
    } >ram_kernel AT>rom
    PROVIDE(ld_kernel_code_lma = LOADADDR(.kernel_code));
    PROVIDE(ld_kernel_code_vma = ADDR(.kernel_code));
    PROVIDE(ld_kernel_code_size = SIZEOF(.kernel_code));

    /* The page tables. Must be aligned to 16K */
    .page_table (NOLOAD) : ALIGN(16K) {
        *(.page_table)
    } >ram_kernel =0x00
    PROVIDE(ld_page_table_vma = ADDR(.page_table));
    PROVIDE(ld_page_table_size = SIZEOF(.page_table));

    /* User code */
    .text : ALIGN(4K) {
        *(.text)
    } >ram AT>rom
    PROVIDE(ld_text_lma = LOADADDR(.text));
    PROVIDE(ld_text_vma = ADDR(.text));
    PROVIDE(ld_text_size = SIZEOF(.text));

    /* Initialized data */
    .data : ALIGN(4K) {
        *(.data)
    } >ram AT>rom
    PROVIDE(ld_data_lma = LOADADDR(.data));
    PROVIDE(ld_data_vma = ADDR(.data));
    PROVIDE(ld_data_size = SIZEOF(.data));

    /* Unitialized data */
    .bss (NOLOAD) : ALIGN(4K) {
        *(.bss)
    } >ram =0x00
    PROVIDE(ld_bss_vma = ADDR(.bss));
    PROVIDE(ld_bss_size = SIZEOF(.bss));

    /* Stack for all operation modes */
    .stack (NOLOAD) : ALIGN(4K) {
        *(.stack)
    } >ram
    PROVIDE(ld_stack_vma = ADDR(.stack));
    PROVIDE(ld_stack_size = SIZEOF(.stack));
}
