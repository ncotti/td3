#include "task1.h"

extern uint32_t task1_reading_area;

/// @brief Entrypoint for the task1.
void task1(void) {
    bool mem_ok;
    while(1) {
        mem_ok = task1_memtest(&task1_reading_area, TASK1_READING_AREA_SIZE);
        if (!mem_ok) {
            critical_error(ERROR_MEMTEST);
        }
    }
}

/// @brief Checks if a memory section is valid by writing and reading 0xAA55AA55
///   in all its extension.
/// @param mem_origin Start of the memory region.
/// @param mem_size Size of the memory region.
/// @return TRUE if the whole extent of the memory region is accessible, FALSE
///   otherwise.
bool task1_memtest(uint32_t* mem_origin, uint32_t mem_size) {
    uint32_t read_before, read_after;
    uint32_t* addr = mem_origin;
    uint32_t mem_index = 0;
    mem_size = mem_size / sizeof(uint32_t);
    do {
        read_before = 0;
        read_after = 0;
        read_before = read_privileged_data(&addr[mem_index]);
        write_privileged_data(&addr[mem_index], PATTERN);
        read_after = read_privileged_data(&addr[mem_index]);
        write_privileged_data(&addr[mem_index], read_before);
        if (read_after != PATTERN) {
            return FALSE;
        }
        mem_index++;
    } while (mem_index < mem_size);
    return TRUE;
}
