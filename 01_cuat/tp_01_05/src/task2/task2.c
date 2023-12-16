#include "task2.h"

extern uint32_t task2_reading_area;

/// @brief Entrypoint for the task2.
void task2(void) {
    bool mem_ok;
    while(1) {
        mem_ok = task2_memtest(&task2_reading_area, TASK2_READING_AREA_SIZE);
        if (!mem_ok) {
            ERROR(ERROR_MEMTEST);
        }
    }
}

/// @brief Checks if a memory section is valid by inverting all its bits.
/// @param mem_origin Start of the memory region.
/// @param mem_size Size of the memory region.
/// @return TRUE if the whole extent of the memory region is accessible, FALSE
///   otherwise.
bool task2_memtest(uint32_t* mem_origin, uint32_t mem_size) {
    uint32_t read_before, read_after;
    uint32_t* addr = mem_origin;
    uint32_t mem_index = 0;
    mem_size = mem_size / sizeof(uint32_t);
    do {
        read_before  = 0;
        read_after = 0;
        read_before = addr[mem_index];
        addr[mem_index] = ~read_before;
        read_after = addr[mem_index];
        addr[mem_index] = read_before;
        if (read_after != ~read_before) {
            return FALSE;
        }
        mem_index++;
    } while(mem_index < mem_size);
    return TRUE;
}
