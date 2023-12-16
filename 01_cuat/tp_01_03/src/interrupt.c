#include "interrupt.h"

/// @brief IRQ handler. Detects the current IRQ, and calls the corresponding
///     handler.
void C_IRQ_Handler(void) {
    interrupt_id id = gic_get_id();

    switch (id) {
        case INT_TIMER_0_AND_1:
            if (timer_interrupted(TIMER0)) {
                TIMER0->irq_handler();
            } else {
                TIMER1->irq_handler();
            }
        break;

        case INT_TIMER_2_AND_3:
            if (timer_interrupted(TIMER2)) {
                TIMER2->irq_handler();
            } else {
                TIMER3->irq_handler();
            }
        break;

        case INT_TIMER_4_AND_5:
            if (timer_interrupted(TIMER4)) {
                TIMER4->irq_handler();
            } else {
                TIMER5->irq_handler();
            }
        break;

        case INT_TIMER_6_AND_7:
            if (timer_interrupted(TIMER6)) {
                TIMER6->irq_handler();
            } else {
                TIMER7->irq_handler();
            }
        break;

        case INT_ERROR:
        break;
    }
}

void timer_irq_handler(void) {
    timer_irq_asm();
    timer_clear_interrupt(TIMER0);
}
