#include "config.h"

#ifdef ENABLE_TESTING

#include "testing.h"

/******************************************************************************
 * Static functions prototypes
******************************************************************************/

static void prv_test_timer_no_int(timer_dev* timer);
static void prv_test_timer_int(timer_dev* timer, void(*handler)(void), uint8_t test_id);

static void prv_timer0_irq(void);
static void prv_timer1_irq(void);
static void prv_timer2_irq(void);
static void prv_timer3_irq(void);

/******************************************************************************
 * Variables
******************************************************************************/
const uint32_t read_only_var = 55;
static uint8_t timer_flag = TESTING_START;

/******************************************************************************
 * Test conditions
******************************************************************************/
/// @brief Assert equality. In case of error, execution aborts.
/// @param tested_value
/// @param expected_value
void assert_eq(uint32_t tested_value, uint32_t expected_value) {
    if (tested_value != expected_value) {
        test_failed(expected_value);
    }
}

/// @brief Assert greater than. In case of error, execution aborts.
/// @param value
/// @param expected_value
void assert_gt(uint32_t value, uint32_t expected_value) {
    if (value <= expected_value) {
        test_failed(TESTING_START);
    }
}

/******************************************************************************
 * General tests
******************************************************************************/
/// @brief Extension of the function "prv_test_syscalls" in C.
void test_syscalls(void) {
    uint8_t value = TESTING_START;
    value = privileged_kernel_function();
    assert_eq(value, TESTING_KERNEL_FUNCTION);
    SYS(value = get_pref_return());
    assert_eq(value, TESTING_INSTRUCTION_PERMISSION_ABORT);
}

/// @brief Test software IRQ.
void test_software_irq(void) {
    uint8_t irq_return = TESTING_START;
    SYS(gic_set_swi());
    SYS(irq_return = get_irq_return());
    assert_eq(irq_return, TESTING_SOFTWARE_IRQ);
}

/******************************************************************************
 * Timer tests
******************************************************************************/
/// @brief Test operation of the timers. Timers 4 to 7 don't work.
void test_timers(void) {
    SYS(prv_test_timer_no_int(TIMER0));
    SYS(prv_test_timer_no_int(TIMER1));
    SYS(prv_test_timer_no_int(TIMER2));
    SYS(prv_test_timer_no_int(TIMER3));

    SYS(prv_test_timer_int(TIMER0, prv_timer0_irq, TESTING_TIMER0));
    SYS(prv_test_timer_int(TIMER1, prv_timer1_irq, TESTING_TIMER1));
    SYS(prv_test_timer_int(TIMER2, prv_timer2_irq, TESTING_TIMER2));
    SYS(prv_test_timer_int(TIMER3, prv_timer3_irq, TESTING_TIMER3));
}

/// @brief Test timer functionality without enabling interrupts.
/// @param timer Timer device
static void prv_test_timer_no_int(timer_dev* timer) {
    uint32_t delay, i, time_left;

    // Testing ONE_SHOT mode
    timer_init(timer, 10000, TIMER_MODE_ONE_SHOT, FALSE, prv_timer0_irq);
    time_left = timer_time_us(timer);
    assert_gt(time_left, 0);
    delay = 0; while (delay++ < 100000U);
    time_left = timer_time_us(timer);
    assert_eq(time_left, 0);

    // Change to periodic, and test 3 times.
    timer_set_mode(timer, TIMER_MODE_PERIODIC);
    timer_load_us(timer, 10000);
    assert_gt(timer_time_us(timer), 0);
    i = 0;
    while(i < 3) {
        if (timer_time_us(timer) < 1000) {
            i++;
        }
    }

    // Test the timer actually stopping
    timer_pause(timer);
    timer_load_us(timer, 12345);
    delay = 0; while (delay++ < 100000U);
    assert_eq(timer_time_us(timer), 12345);
}

/// @brief Test timer functionality enabling interrupts
/// @param timer
/// @param handler
/// @param test_id
static void prv_test_timer_int(timer_dev* timer, void(*handler)(void), uint8_t test_id) {
    uint32_t i = 0, delay = 0;
    timer_init(timer, 10000, TIMER_MODE_PERIODIC, TRUE, handler);
    while (i++ < 3) {
        timer_flag = TESTING_START;
        asm("WFI");
        assert_eq(timer_flag, test_id);
    }
    timer_pause(timer);
    timer_flag = TESTING_START;
    while(delay++ < 100000U);
    assert_eq(timer_flag, TESTING_START);
}

static void prv_timer0_irq(void) {
    timer_flag = TESTING_TIMER0;
    timer_clear_interrupt(TIMER0);
}

static void prv_timer1_irq(void) {
    timer_flag = TESTING_TIMER1;
    timer_clear_interrupt(TIMER1);
}

static void prv_timer2_irq(void) {
    timer_flag = TESTING_TIMER2;
    timer_clear_interrupt(TIMER2);
}

static void prv_timer3_irq(void) {
    timer_flag = TESTING_TIMER3;
    timer_clear_interrupt(TIMER3);
}

#endif // ENABLE_TESTING

