#include "int_handlers.h"

// Return values from some of the exception handlers.
PUBLIC_DATA uint32_t und_return = 0;
PUBLIC_DATA uint32_t pref_return = 0;
PUBLIC_DATA uint32_t abt_return = 0;
PUBLIC_DATA uint32_t irq_return = 0;

/// @brief Checks the reason of the prefetch handler, and acts accordingly.
/// @param fault Fault number
/// @param addr Address that caused the fault
/// @return If "0", return to the same instruction that caused the fault.
///   If "!0", return to the same instruction, but in SYS_MODE.
uint8_t pref_handler(instruction_fault fault, uint32_t* addr) {
    uint8_t where_to_return = RETURN_TO_SAME;
    switch(fault) {
    case IF_PERMISSION_SECTION:
        #ifdef ENABLE_TESTING
            where_to_return = TESTING_INSTRUCTION_PERMISSION_ABORT;
        #else
            asm("nop");
        #endif
    break;
    case IF_PERMISSION_PAGE:
        #ifdef ENABLE_TESTING
            where_to_return = TESTING_INSTRUCTION_PERMISSION_ABORT;
        #else
            asm("nop");
        #endif
    break;
    case IF_ACCESS_FLAG_PAGE: asm("nop"); break;
    case IF_ACCESS_FLAG_SECTION: asm("nop"); break;
    case IF_DOMAIN_PAGE: asm("nop"); break;
    case IF_DOMAIN_SECTION: asm("nop"); break;
    case IF_PAGE_TRANSLATION: asm("nop"); break;
    case IF_SECTION_TRANSLATION: asm("nop"); break;
    case IF_TABLE1_EXTERNAL_ABORT: asm("nop"); break;
    case IF_TABLE1_PARITY_ERROR: asm("nop"); break;
    case IF_TABLE2_EXTERNAL_ABORT: asm("nop"); break;
    case IF_TABLE2_PARITY_ERROR: asm("nop"); break;
    default: asm("nop"); break;
    }
    return where_to_return;
}

/// @brief Checks the reason of the data abort handler, and acts accordingly.
/// @param fault Fault number
/// @param addr Address that caused the fault.
/// @param read_write Whether it was because a read access or a write access
/// @return If "0", return to the same instruction that caused the fault.
///   If "!0", return to the next instruction, skipping the faulty one.
uint8_t abt_handler(data_fault fault, uint32_t* addr, rw_fault rw) {
    uint8_t where_to_return = RETURN_TO_SAME;
    switch(fault) {
    case DF_ALIGNMENT:
        #ifdef ENABLE_TESTING
            where_to_return = TESTING_ALIGNMENT_FAULT;
        #else
            asm("nop");
        #endif
    break;
    case DF_SECTION_TRANSLATION:
        #ifdef ENABLE_MEMORY_MAPPING_FROM_ABORT
            mmu_fill_pte_from_vma(addr);
            where_to_return = RETURN_TO_SAME;
        #else
            asm("nop");
        #endif
    break;
    case DF_PAGE_TRANSLATION:
        #ifdef ENABLE_MEMORY_MAPPING_FROM_ABORT
            mmu_fill_pte_from_vma(addr);
            where_to_return = RETURN_TO_SAME;
        #else
            asm("nop");
        #endif
    break;
    case DF_PERMISSION_PAGE:
        if (rw == READ_ACCESS) {
            #ifdef ENABLE_TESTING
                where_to_return = TESTING_DATA_READ_FAULT;
            #else
                asm("nop");
            #endif
        }
        else if (rw == WRITE_ACCESS) {
            #ifdef ENABLE_TESTING
                where_to_return = TESTING_DATA_WRITE_FAULT;
            #else
                asm("nop");
            #endif
        }
    break;
    case DF_PERMISSION_SECTION: asm("nop"); break;
    case DF_ACCESS_FLAG_PAGE: asm("nop"); break;
    case DF_ACCESS_FLAG_SECTION: asm("nop"); break;
    case DF_CACHE_MAINTENANCE: asm("nop"); break;
    case DF_DOMAIN_PAGE: asm("nop"); break;
    case DF_DOMAIN_SECTION: asm("nop"); break;
    case DF_TABLE1_EXTERNAL_ABORT: asm("nop"); break;
    case DF_TABLE1_PARITY_ERROR: asm("nop"); break;
    case DF_TABLE2_EXTERNAL_ABORT: asm("nop"); break;
    case DF_TABLE2_PARITY_ERROR: asm("nop"); break;
    default: asm("nop"); break;
    }
    return where_to_return;
}

/// @brief Detects the current IRQ, and calls the corresponding handler.
/// @return If the return value is !0, the current context won't be stored, but
///   it will be loaded from the last saved context for the current task.
uint8_t irq_handler(void) {
    uint8_t output = 0;
    interrupt_id id = __gic_get_id();
    switch (id) {
    case INT_TIMER_0_AND_1:
        if (__timer_interrupted(TIMER0)) {
            TIMER0->irq_handler();
        } else {
            TIMER1->irq_handler();
        }
    break;
    case INT_TIMER_2_AND_3:
        if (__timer_interrupted(TIMER2)) {
            TIMER2->irq_handler();
        } else {
            TIMER3->irq_handler();
        }
    break;
    case INT_TIMER_4_AND_5:
        if (__timer_interrupted(TIMER4)) {
            TIMER4->irq_handler();
        } else {
            TIMER5->irq_handler();
        }
    break;
    case INT_TIMER_6_AND_7:
        if (__timer_interrupted(TIMER6)) {
            TIMER6->irq_handler();
        } else {
            TIMER7->irq_handler();
        }
    break;
    case INT_SOFTWARE:
        output = IRQ_DONT_SWITCH_CONTEXT;
        __gic_clear_interrupt(id);
    break;
    case INT_ERROR:
        __critical_error(ERROR_IRQ_INT);
    break;
    default:
        __critical_error(ERROR_UNKNOWN_IRQ);
    break;
    }
    return output;
}
