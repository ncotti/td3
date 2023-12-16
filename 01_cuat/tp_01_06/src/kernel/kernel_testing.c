#include "testing/testing.h"

PUBLIC_DATA uint32_t testing_public_data = TESTING_PUBLIC_DATA;
uint32_t testing_privileged_data = TESTING_PRIVILEGED_DATA;

/******************************************************************************
 * Syscall test functions
******************************************************************************/

SYSCALL_SECTION uint32_t testing_syscall7(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e, uint32_t f, uint32_t g) {
    return (uint32_t) SYSCALL7(a, b, c, d, e, f, g, SYSCALL_TESTING7);
}

uint32_t __testing_syscall7(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e, uint32_t f, uint32_t g) {
    return a + b + c + d + e + f + g;
}

SYSCALL_SECTION uint32_t testing_syscall6(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e, uint32_t f) {
    return (uint32_t) SYSCALL6(a, b, c, d, e, f, SYSCALL_TESTING6);
}

uint32_t __testing_syscall6(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e, uint32_t f) {
    return a + b + c + d + e + f;
}

SYSCALL_SECTION uint32_t testing_syscall5(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e) {
    return (uint32_t) SYSCALL5(a, b, c, d, e, SYSCALL_TESTING5);
}

uint32_t __testing_syscall5(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d, uint32_t e) {
    return a + b + c + d + e;
}

SYSCALL_SECTION uint32_t testing_syscall4(uint32_t a, uint32_t b, uint32_t c,
        uint32_t d) {
    return (uint32_t) SYSCALL4(a, b, c, d, SYSCALL_TESTING4);
}

uint32_t __testing_syscall4(uint32_t a, uint32_t b, uint32_t c, uint32_t d) {
    return a + b + c + d;
}

SYSCALL_SECTION uint32_t testing_syscall3(uint32_t a, uint32_t b, uint32_t c) {
    return (uint32_t) SYSCALL3(a, b, c, SYSCALL_TESTING3);
}

uint32_t __testing_syscall3(uint32_t a, uint32_t b, uint32_t c) {
    return a + b + c;
}

SYSCALL_SECTION uint32_t testing_syscall2(uint32_t a, uint32_t b) {
    return (uint32_t) SYSCALL2(a, b, SYSCALL_TESTING2);
}

uint32_t __testing_syscall2(uint32_t a, uint32_t b) {
    return a + b;
}

SYSCALL_SECTION uint32_t testing_syscall1(uint32_t a) {
    return (uint32_t) SYSCALL1(a, SYSCALL_TESTING1);
}

uint32_t __testing_syscall1(uint32_t a) {
    return a;
}

SYSCALL_SECTION uint32_t testing_syscall0(void) {
    return (uint32_t) SYSCALL0(SYSCALL_TESTING0);
}

uint32_t __testing_syscall0(void) {
    return 55;
}
