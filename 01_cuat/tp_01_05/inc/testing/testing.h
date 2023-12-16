#include "types.h"
#include "timer.h"
#include "syscalls.h"
#include "test_codes.h"
#include "gic.h"

/******************************************************************************
 * Function prototypes
******************************************************************************/

void assert_eq(uint32_t tested_value, uint32_t expected_value);
void assert_gt(uint32_t value, uint32_t expected_value);

void test_syscalls(void);
void test_timers(void);

extern uint8_t get_irq_return(void);
extern uint8_t get_pref_return(void);
extern uint8_t privileged_kernel_function(void);
extern void test_failed(uint8_t test_number);
