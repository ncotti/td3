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
    uint32_t out = TESTING_START;
    out = testing_syscall7(1,2,3,4,5,6,7);
    assert_eq(out, 1+2+3+4+5+6+7);
    out = testing_syscall6(1,2,3,4,5,6);
    assert_eq(out, 1+2+3+4+5+6);
    out = testing_syscall5(1,2,3,4,5);
    assert_eq(out, 1+2+3+4+5);
    out = testing_syscall4(1,2,3,4);
    assert_eq(out, 1+2+3+4);
    out = testing_syscall3(1,2,3);
    assert_eq(out, 1+2+3);
    out = testing_syscall2(1,2);
    assert_eq(out, 1+2);
    out = testing_syscall1(1);
    assert_eq(out, 1);
    out = testing_syscall0();
    assert_eq(out, 55);
    out = __testing_syscall0(); // Prefetch abort expected
    asm volatile("cps 0x10");
    assert_eq(pref_return, TESTING_INSTRUCTION_PERMISSION_ABORT);
}

/******************************************************************************
 * Timer tests
******************************************************************************/
/// @brief Test operation of the timers. Timers 4 to 7 don't work.
void test_timers(void) {
    prv_test_timer_no_int(TIMER0);
    prv_test_timer_no_int(TIMER1);
    prv_test_timer_no_int(TIMER2);
    prv_test_timer_no_int(TIMER3);

    prv_test_timer_int(TIMER0, prv_timer0_irq, TESTING_TIMER0);
    prv_test_timer_int(TIMER1, prv_timer1_irq, TESTING_TIMER1);
    prv_test_timer_int(TIMER2, prv_timer2_irq, TESTING_TIMER2);
    prv_test_timer_int(TIMER3, prv_timer3_irq, TESTING_TIMER3);
}

/// @brief Test timer functionality without enabling interrupts.
/// @param timer Timer device
static void prv_test_timer_no_int(timer_dev* timer) {
    uint32_t delay, i, time_left;

    // Testing ONE_SHOT mode
    timer_init(timer, 10000, TIMER_MODE_ONE_SHOT, FALSE, prv_timer0_irq);
    time_left = timer_time_us(timer);
    assert_gt(time_left, 0);
    delay = 0; while (delay++ < 10000000U && timer_time_us(timer) > 0);
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

/******************************************************************************
 * NEON tests
******************************************************************************/
#ifdef ENABLE_NEON
/// @brief Test neon functionality with C intrinsics
void test_neon(void) {
    uint16_t neon_load[8] = {
        0x1, 0x10,
        0x2, 0x20,
        0x3, 0x30,
        0x4, 0x40
    };

    uint16x4x2_t neon_ans;  // neon_ans[0] = D0; neon_ans[1] = D1
    neon_ans = vld2_u16(neon_load);
    neon_ans.val[0] = vadd_u16(neon_ans.val[0], neon_ans.val[1]);
    assert_eq(neon_ans.val[0][0], 0x11);    // neon_ans.val[0][0] = D0[0]
    assert_eq(neon_ans.val[0][1], 0x22);
    assert_eq(neon_ans.val[0][2], 0x33);
    assert_eq(neon_ans.val[0][3], 0x44);
}
#endif // ENABLE_NEON
#endif // ENABLE_TESTING

