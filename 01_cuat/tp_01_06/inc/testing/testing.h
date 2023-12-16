#include "types.h"
#include "timer.h"
#include "syscalls.h"
#include "test_codes.h"
#include "gic.h"
#include "int_handlers.h"
#include "config.h"

/******************************************************************************
 * Function prototypes
******************************************************************************/

void assert_eq(uint32_t tested_value, uint32_t expected_value);
void assert_gt(uint32_t value, uint32_t expected_value);

void test_syscalls(void);
void test_timers(void);
extern void test_failed(uint8_t test_number);

#ifdef ENABLE_NEON
    #include <arm_neon.h>
    void test_neon(void);
#endif

// Testing syscalls
uint32_t testing_syscall0(void);
uint32_t __testing_syscall0(void);

uint32_t testing_syscall1(uint32_t a);
uint32_t __testing_syscall1(uint32_t a);

uint32_t testing_syscall2(uint32_t a, uint32_t b);
uint32_t __testing_syscall2(uint32_t a, uint32_t b);

uint32_t testing_syscall3(uint32_t a, uint32_t b, uint32_t c);
uint32_t __testing_syscall3(uint32_t a, uint32_t b, uint32_t c);

uint32_t testing_syscall4(uint32_t a, uint32_t b, uint32_t c, uint32_t d);
uint32_t __testing_syscall4(uint32_t a, uint32_t b, uint32_t c, uint32_t d);

uint32_t testing_syscall5(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e);
uint32_t __testing_syscall5(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e);

uint32_t testing_syscall6(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e, uint32_t f);
uint32_t __testing_syscall6(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e, uint32_t f);

uint32_t testing_syscall7(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e, uint32_t f, uint32_t g);
uint32_t __testing_syscall7(uint32_t a, uint32_t b, uint32_t c, uint32_t d,
    uint32_t e, uint32_t f, uint32_t g);
