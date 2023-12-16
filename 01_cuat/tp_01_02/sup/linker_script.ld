/*-----------------------------------------------------------------------------
*   Output format
-----------------------------------------------------------------------------*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(RESET_handler)

/*-----------------------------------------------------------------------------
*   Memory regions' origins and lengths
-----------------------------------------------------------------------------*/
HIDDEN (ld_rom_origin   = 0x70010000);
HIDDEN (ld_stack_origin = 0x70020000);
HIDDEN (ld_ram_origin   = 0x70030000);
HIDDEN (ld_vector_table_origin = 0x00000000);

HIDDEN (ld_rom_length   = 0x1000);
HIDDEN (ld_ram_length   = 0x1000);

/* They should be multiples of 8 */
HIDDEN (ld_user_stack_size  = 0x1000);
HIDDEN (ld_irq_stack_size   = 0x1000);
HIDDEN (ld_fiq_stack_size   = 0x1000);
HIDDEN (ld_svc_stack_size   = 0x1000);
HIDDEN (ld_abt_stack_size   = 0x1000);
HIDDEN (ld_und_stack_size   = 0x1000);
HIDDEN (ld_stack_length = ld_user_stack_size + ld_irq_stack_size +
    ld_fiq_stack_size + ld_svc_stack_size + ld_abt_stack_size +
    ld_und_stack_size);

/*-----------------------------------------------------------------------------
*   Memory sections
-----------------------------------------------------------------------------*/
MEMORY {
    rom     (rx)    :   ORIGIN = ld_rom_origin,     LENGTH = ld_rom_length
    ram     (wa)    :   ORIGIN = ld_ram_origin,     LENGTH = ld_ram_length
    stack   (wa)    :   ORIGIN = ld_stack_origin,   LENGTH = ld_stack_length
}

/*-----------------------------------------------------------------------------
*   Section definitions
-----------------------------------------------------------------------------*/
SECTIONS {
    /*
    * Init section has all the boot code, before changing to user mode
    */
    .init : ALIGN(4) {
        *vector_table*(.init*)
        *(.init*)
    } >rom AT>rom

    /*
    * The vector table has its VMA at 0x00
    */
    .vector_table ld_vector_table_origin : ALIGN(4) {
        *(.vector_table*)
    } AT>rom
    PROVIDE(ld_vector_table_lma = LOADADDR(.vector_table));
    PROVIDE(ld_vector_table_vma = ADDR(.vector_table));
    PROVIDE(ld_vector_table_size = SIZEOF(.vector_table));

    /*
    * User code
    */
    .text : ALIGN(4) {
        *(.text*)
    } >ram AT>rom
    PROVIDE(ld_text_lma = LOADADDR(.text));
    PROVIDE(ld_text_vma = ADDR(.text));
    PROVIDE(ld_text_size = SIZEOF(.text));

    /*
    * Initialized data
    */
    .data : ALIGN(4) {
        *(.text*)
    } >ram AT>rom
    PROVIDE(ld_data_lma = LOADADDR(.data));
    PROVIDE(ld_data_vma = ADDR(.data));
    PROVIDE(ld_data_size = SIZEOF(.data));

    /*
    * Unitialized data
    */
    .bss (NOLOAD) : ALIGN(4) {
        *(.bss*)
    } >ram
    PROVIDE(ld_bss_vma = ADDR(.bss));
    PROVIDE(ld_bss_size = SIZEOF(.bss));
    PROVIDE(ld_bss_pattern = 0x00);

    /*
    * Stack for all operation modes
    */
    .stack (NOLOAD) : ALIGN(8) {
        . += ld_user_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_user_stack_top = .);

        . += ld_irq_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_irq_stack_top = .);

        . += ld_fiq_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_fiq_stack_top = .);

        . += ld_svc_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_svc_stack_top = .);

        . += ld_abt_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_abt_stack_top = .);

        . += ld_und_stack_size;
        . = ALIGN(8);
        PROVIDE(ld_und_stack_top = .);
    } >stack
}
