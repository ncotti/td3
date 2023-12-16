#include "timer.h"

#ifdef TIMER_SP804
/******************************************************************************
 * Definition of the timer devices
******************************************************************************/
static timer_dev timer0 = {
    .regs = TIMER0_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_0_AND_1,
};
timer_dev* TIMER0 = &timer0;

static timer_dev timer1 = {
    .regs = TIMER1_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_0_AND_1,
};
timer_dev* TIMER1 = &timer1;

static timer_dev timer2 = {
    .regs = TIMER2_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_2_AND_3,
};
timer_dev* TIMER2 = &timer2;

static timer_dev timer3 = {
    .regs = TIMER3_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_2_AND_3,
};
timer_dev* TIMER3 = &timer3;

static timer_dev timer4 = {
    .regs = TIMER4_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_4_AND_5,
};
timer_dev* TIMER4 = &timer4;

static timer_dev timer5 = {
    .regs = TIMER5_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_4_AND_5,
};
timer_dev* TIMER5 = &timer5;

static timer_dev timer6 = {
    .regs = TIMER6_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_6_AND_7,
};
timer_dev* TIMER6 = &timer6;

static timer_dev timer7 = {
    .regs = TIMER7_BASE,
    .irq_handler = NO_HANDLER,
    .int_id = INT_TIMER_6_AND_7,
};
timer_dev* TIMER7 = &timer7;

/******************************************************************************
 * Static functions' prototypes
******************************************************************************/
static reg_t* sysctrl0 = SYSCTRL0_BASE;
static reg_t* sysctrl1 = SYSCTRL1_BASE;
static void sysctrl_enable_timer(timer_dev* timer);

/******************************************************************************
 * Functions' declarations
******************************************************************************/
/// @brief Initializes a timer.
/// @param timer Timer device. Must be one of the predefined ones
///     (TIMER0, TIMER1 ..., TIMER 7). Operation frequency is fixed in 1MHz.
/// @param value Time in useg.
/// @param mode Operation mode.
/// @param interrupt If TRUE, enable interrupts for this timer.
/// @param irq_handler Pointer to the irq handler. Can be NO_HANDLER if not needed.
void timer_init(
        timer_dev* timer,
        uint32_t value,
        timer_mode mode,
        bool interrupt,
        void (*irq_handler)(void)) {
    TIMER_SIZE_32BIT(timer->regs->CONTROL);
    TIMER_PRESCALE_1(timer->regs->CONTROL);
    sysctrl_enable_timer(timer);
    timer_set_mode(timer, mode);
    timer_load_us(timer, value);
    if (interrupt) {
        timer_enable_interrupt(timer);
    } else {
        timer_disable_int(timer);
    }
    timer->irq_handler = irq_handler;
    timer_reset(timer);
}

/// @brief Resume timer operation.
/// @param timer Timer device.
void timer_resume(timer_dev* timer) {
    TIMER_ENABLE(timer->regs->CONTROL);
}

/// @brief Pause the timer. The count value will be preserved.
/// @param timer Timer device
void timer_pause(timer_dev* timer) {
    TIMER_DISABLE(timer->regs->CONTROL);
}

/// @brief Reset timer from the last loaded value. The count value
///     will be overwritten. The timer will be resumed if paused.
/// @param timer Timer device.
void timer_reset(timer_dev* timer) {
    timer->regs->VALUE = timer->regs->LOAD;
    TIMER_ENABLE(timer->regs->CONTROL);
}

/// @brief Set the count for the timer. The timer won't be resumed, and the
///     current count value will be preserved until it expires.
///     Use "timer_reset" or "timer_resume" to start operation.
/// @param timer Timer device.
/// @param value Time in milliseconds.
void timer_load_ms(timer_dev* timer, uint32_t value) {
    timer_load_us(timer, value*1000);
}

/// @brief Set the count for the timer. The timer won't be resumed, and the
///     current count value will be preserved until it expires.
///     Use "timer_reset" or "timer_resume" to start operation.
/// @param timer Timer device.
/// @param value Time in microseconds.
void timer_load_us(timer_dev* timer, uint32_t value) {
    timer->regs->LOAD  = value; // Timer runs at 1Mhz -> 1tick = 1us
}

/// @brief Sets the operation mode for the timer, possibilities are:
///     - TIMER_MODE_FREE_RUNNING: Goes from 0xFFFF_FFFF to 0x0000_0000
///     - TIMER_MODE_ONE_SHOT: Goes from certain value to 0x0000_0000 and stops
///     - TIMER_MODE_PERIODIC: Goes from certain value to 0x0000_0000 and repeats
/// @param timer Timer device.
/// @param mode Operation mode.
void timer_set_mode(timer_dev* timer, timer_mode mode) {
    switch (mode) {
        case TIMER_MODE_PERIODIC:
            // PERIODIC and FREE_RUNNING are inverted in the docs
            TIMER_FREE_RUNNING(timer->regs->CONTROL);
            TIMER_WRAPPING(timer->regs->CONTROL);
        break;

        case TIMER_MODE_ONE_SHOT:
            TIMER_ONE_SHOT(timer->regs->CONTROL);
        break;

        case TIMER_MODE_FREE_RUNNING:
            TIMER_PERIODIC(timer->regs->CONTROL);
            TIMER_WRAPPING(timer->regs->CONTROL);
        break;
    }
}

/// @brief Enables interrupts for this timer.
/// @param timer Timer device.
void timer_enable_interrupt(timer_dev* timer) {
    TIMER_ENABLE_INT(timer->regs->CONTROL);
    gic_enable_interrupt(timer->int_id);
}

/// @brief Disables interrupts for the timer. It does not clear it.
/// @param timer Timer device.
void timer_disable_int(timer_dev* timer) {
    TIMER_DISABLE_INT(timer->regs->CONTROL);
    gic_disable_interrupt(timer->int_id);
}

/// @brief Clears the interrupt flag. Must be called inside the interrupt handler.
/// @param timer Timer device.
void timer_clear_interrupt(timer_dev* timer) {
    TIMER_CLEAR_INT(timer->regs->INTCLR);
    gic_clear_interrupt(timer->int_id);
}

/// @brief Returns the time left in milliseconds, rounded upwards.
/// @param timer Timer device.
/// @return Time left in milliseconds, rounded upwards.
uint32_t timer_time_ms(timer_dev* timer) {
    return ((timer->regs->VALUE + 999)/ 1000);   // freq = 1Mhz, 1tick = 1us
}

/// @brief Returns the time left in microseconds. Result is exact.
/// @param timer Timer device.
/// @return Time left in microseconds.
uint32_t timer_time_us(timer_dev* timer) {
    return timer->regs->VALUE;   // freq = 1Mhz, 1tick = 1us
}

/// @brief Check if the timer produced the interruption.
/// @param timer Timer device.
/// @return TRUE if the timer interrupted.
bool timer_interrupted(timer_dev* timer) {
    return timer->regs->RIS & 0x1;
}

/******************************************************************************
 * Static functions declarations
******************************************************************************/
/// @brief Enable the clock input for the timer. Only possible value is 1MHz.
/// @param timer Timer device.
static void sysctrl_enable_timer(timer_dev* timer) {
    if (timer == TIMER0) {
        SYSCTRL_TIMER0_1M(*sysctrl0);
    } else if (timer == TIMER1) {
        SYSCTRL_TIMER1_1M(*sysctrl0);
    } else if (timer == TIMER2) {
        SYSCTRL_TIMER2_1M(*sysctrl0);
    } else if (timer == TIMER3) {
        SYSCTRL_TIMER3_1M(*sysctrl0);
    } else if (timer == TIMER4) {
        SYSCTRL_TIMER4_1M(*sysctrl1);
    } else if (timer == TIMER5) {
        SYSCTRL_TIMER5_1M(*sysctrl1);
    } else if (timer == TIMER6) {
        SYSCTRL_TIMER6_1M(*sysctrl1);
    } else if (timer == TIMER7) {
        SYSCTRL_TIMER7_1M(*sysctrl1);
    }
}

#endif // TIMER_SP804