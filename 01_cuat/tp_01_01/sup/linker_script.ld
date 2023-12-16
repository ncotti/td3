OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

ld_rom_origin   = 0x70010000;
ld_stack_origin = 0x70020000;
ld_ram_origin   = 0x70030000;

ld_rom_length   = 0x1000;
ld_ram_length   = 0x1000;
ld_stack_length = 0x1000;

MEMORY {
    rom     (rx)    :   ORIGIN = ld_rom_origin,     LENGTH = ld_rom_length
    ram     (wa)    :   ORIGIN = ld_ram_origin,     LENGTH = ld_ram_length
    stack   (wa)    :   ORIGIN = ld_stack_origin,   LENGTH = ld_stack_length
}

SECTIONS {
    .init : {
        *(.init*)
    } >rom AT>rom

    .text : ALIGN(4) {
        *(.text*)
    } >ram AT>rom
    PROVIDE(ld_text_section_lma = LOADADDR(.text));
    PROVIDE(ld_text_section_vma = ADDR(.text));
    PROVIDE(ld_text_section_size = SIZEOF(.text));

    .data : ALIGN(4) {
        *(.text*)
    } >ram AT>rom
    PROVIDE(ld_data_section_lma = LOADADDR(.data));
    PROVIDE(ld_data_section_vma = ADDR(.data));
    PROVIDE(ld_data_section_size = SIZEOF(.data));
}