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
ld_rom_length           = 0x10000;

/* Part of the ram where memory can be allocated as needed by the OS,
*  with no particular physical address (NO_PA) */
ld_free_ram_origin      = 0x80000000;
ld_free_ram_length      = 0x10000000;

/* Part of the ram where fixed physical addresses are used */
ld_fixed_ram_origin     = ld_rom_origin + ld_rom_length;
ld_fixed_ram_length     = ld_free_ram_origin - ld_fixed_ram_origin;


/******************************************************************************
*   Memory sections
******************************************************************************/
MEMORY {
    rom         (rx) :  ORIGIN = ld_rom_origin,         LENGTH = ld_rom_length
    fixed_ram   (wa) :  ORIGIN = ld_fixed_ram_origin,   LENGTH = ld_fixed_ram_length
    free_ram    (wa) :  ORIGIN = ld_free_ram_origin,    LENGTH = ld_free_ram_length
}

/******************************************************************************
*   Section definitions
******************************************************************************/
SECTIONS {
    INCLUDE "src/kernel/kernel.ld"
    INCLUDE "src/task1/task1.ld"
    INCLUDE "src/task2/task2.ld"
    INCLUDE "src/testing/testing.ld"
}


