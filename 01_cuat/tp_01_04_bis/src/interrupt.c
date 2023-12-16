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

uint8_t data_abort_handler(data_fault fault, uint32_t* addr, uint32_t read_write) {
    // Status = 0; repeat instruction that caused abort
    // Status = 1; Ignore and continue with next instruction
    uint8_t status = 0;
    switch(fault) {
        case DF_ACCESS_FLAG_PAGE:
        asm("nop");
        break;

        case DF_ACCESS_FLAG_SECTION:
        asm("nop");
        break;

        case DF_ALIGNMENT:
        status = 1;
        break;

        case DF_CACHE_MAINTENANCE:
        asm("nop");
        break;

        case DF_DOMAIN_PAGE:
        asm("nop");
        break;

        case DF_DOMAIN_SECTION:
        asm("nop");
        break;

        case DF_PAGE_TRANSLATION:
        mmu_fill_pte_from_vma(addr);
        status = 0;
        break;

        case DF_PERMISSION_SECTION:
        asm("nop");
        break;

        case DF_PERMISSION_PAGE:
        if (read_write == READ_ACCESS) {
            asm("nop");
        }
        else {
            asm("nop");
        }
        status = 1;
        break;

        case DF_SECTION_TRANSLATION:
        mmu_fill_pte_from_vma(addr);
        status = 0;
        break;

        case DF_TABLE1_EXTERNAL_ABORT:
        asm("nop");
        break;

        case DF_TABLE1_PARITY_ERROR:
        asm("nop");
        break;

        case DF_TABLE2_EXTERNAL_ABORT:
        asm("nop");
        break;

        case DF_TABLE2_PARITY_ERROR:
        asm("nop");
        break;

        default:
        asm("nop");
        break;
    }
    return status;
}

uint8_t pre_abort_handler(instruction_fault fault, uint32_t* addr) {
    uint8_t status = 0;
    switch(fault) {
        case IF_ACCESS_FLAG_PAGE:
        asm("nop");
        break;

        case IF_ACCESS_FLAG_SECTION:
        asm("nop");
        break;

        case IF_DOMAIN_PAGE:
        asm("nop");
        break;

        case IF_DOMAIN_SECTION:
        asm("nop");
        break;

        case IF_PAGE_TRANSLATION:
        asm("nop");
        break;

        case IF_PERMISSION_PAGE:
        status = 1;
        break;

        case IF_PERMISSION_SECTION:
        asm("nop");
        break;

        case IF_SECTION_TRANSLATION:
        asm("nop");
        break;

        case IF_TABLE1_EXTERNAL_ABORT:
        asm("nop");
        break;

        case IF_TABLE1_PARITY_ERROR:
        asm("nop");
        break;

        case IF_TABLE2_EXTERNAL_ABORT:
        asm("nop");
        break;

        case IF_TABLE2_PARITY_ERROR:
        asm("nop");
        break;

        default:
        asm("nop");
        break;
    }
    return status;
}
