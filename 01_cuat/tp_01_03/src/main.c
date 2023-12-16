#include "main.h"

/// @brief Main function.
/// @return "0" on success. Anything else on error.
int main(void) {
    uint32_t time = 0;
    time++; // Avoid unused variable
    timer_init(TIMER0, 100000, TIMER_MODE_PERIODIC, TRUE, timer_irq_handler);
    while (1) {
        time = timer_time_us(TIMER0);   // Time is used to keep track of the timer value
        time = timer_time_us(TIMER0);
        asm("WFI");
    }
}

