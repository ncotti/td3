/******************************************************************************
*   Output format
******************************************************************************/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(RESET_handler)

/******************************************************************************
*   Memory regions' origins and lengths
******************************************************************************/
HIDDEN(ld_rom_origin           = 0x70010000);
HIDDEN(ld_rom_length           = 0x10000);

/* The kernel ram space is separated from the rest. This ensures that non
 * overlapping VMAs exist between the kernel and the tasks */
HIDDEN(ld_kernel_ram_origin     = ld_rom_origin + ld_rom_length);
HIDDEN(ld_ram_length     = 0x01000000);

/* NOTE: theoretically, each VMA could be the same and no problems should appear
 * in the code, because each task has it's own page table. However, I believe
 * there is a bug with the gdb or the QEMU when that's the case, and starts
 * acting strange. */
HIDDEN(ld_task1_ram_origin    = ld_kernel_ram_origin + ld_ram_length);
HIDDEN(ld_task2_ram_origin    = ld_task1_ram_origin  + ld_ram_length);
HIDDEN(ld_testing_ram_origin  = ld_task2_ram_origin  + ld_ram_length);

/* Part of the ram where memory can be allocated as needed by the OS,
*  with no particular physical address (NO_PA) */
ld_free_ram_origin      = 0x80000000;
ld_free_ram_length      = 0x10000000;

/******************************************************************************
*   Memory sections
******************************************************************************/
MEMORY {
    rom         (rx) :  ORIGIN = ld_rom_origin,         LENGTH = ld_rom_length
    kernel_ram  (wa) :  ORIGIN = ld_kernel_ram_origin,  LENGTH = ld_ram_length
    free_ram    (wa) :  ORIGIN = ld_free_ram_origin,    LENGTH = ld_free_ram_length
    task1_ram   (wa) :  ORIGIN = ld_task1_ram_origin,   LENGTH = ld_ram_length
    task2_ram   (wa) :  ORIGIN = ld_task2_ram_origin,   LENGTH = ld_ram_length
    testing_ram (wa) :  ORIGIN = ld_testing_ram_origin, LENGTH = ld_ram_length
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
