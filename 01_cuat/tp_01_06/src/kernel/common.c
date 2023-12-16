#include "common.h"

/// @brief Generate a pseudo-random number
SYSCALL_SECTION uint32_t get_random(void) {
    return (uint32_t) SYSCALL0(SYSCALL_GET_RANDOM);
}

uint32_t __get_random(void) {
    static uint32_t last_value = 0;
    last_value = 0x314159265 * last_value + 0x1234567;
    return last_value;
}

/// @brief Reaching to this function means that something went terrible wrong.
/// @param error_code The error number.
SYSCALL_SECTION void critical_error(uint32_t error_code) {
    SYSCALL1(error_code, SYSCALL_CRITICAL_ERROR);
}

void __critical_error(uint32_t error_code) {
    while(1) {
        asm("nop");
    }
}

/// @brief Reads a privileged address, and returns it's value.
SYSCALL_SECTION uint32_t read_privileged_data(uint32_t* addr) {
    return (uint32_t) SYSCALL1(addr, SYSCALL_READ_PRIVILEGED_DATA);
}

uint32_t __read_privileged_data(uint32_t* addr) {
    return *addr;
}

/// @brief Writes to a privileged data address.
SYSCALL_SECTION void write_privileged_data(uint32_t* addr, uint32_t value) {
    SYSCALL2(addr, value, SYSCALL_WRITE_PRIVILEGED_DATA);
}

void __write_privileged_data(uint32_t* addr, uint32_t value) {
    *addr = value;
}
