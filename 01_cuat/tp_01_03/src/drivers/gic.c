#include "gic.h"

#ifdef GIC

/******************************************************************************
 * Device declaration
******************************************************************************/

static gic_dev gic0 = {
    .cpu_regs           = GIC0_CPU_BASE,
    .dist_regs          = GIC0_DIST_BASE,
};

/******************************************************************************
 * Static functions' prototypes
******************************************************************************/

static void gic_enable();

/******************************************************************************
 * Functions' declarations
******************************************************************************/

/// @brief Enables the interrupt. TODO priority handling
/// @param id Interrupt ID.
void gic_enable_interrupt(interrupt_id id) {
    gic_enable();
    if (id <= 63 && id >= 32) {
        gic0.dist_regs->SET_ENABLE[1] |= (1U << (id - 32));
    } else if (id <= 95 && id >= 64) {
        gic0.dist_regs->SET_ENABLE[2] |= (1U << (id - 64));
    }
}

/// @brief Disables the interrupt. It doesn't clear it.
/// @param id Interrupt ID.
void gic_disable_interrupt(interrupt_id id) {
    if (id <= 63 && id >= 32) {
        gic0.dist_regs->SET_ENABLE[1] &= ~(1U << (id - 32));
    } else if (id <= 95 && id <= 64) {
        gic0.dist_regs->SET_ENABLE[2] &= ~(1U << (id - 64));
    }
}

/// @brief Gets the interrupt ID of the current IRQ.
/// @return The interrupt ID. The ID "INT_ERROR" in case of an error.
interrupt_id gic_get_id(void) {
    return (gic0.cpu_regs->INT_ACK & 0x3FFU);
}

/// @brief Returns the priority of the current IRQ.
/// @return IRQ priority (0 (higher) - 15 (lower))
interrupt_id gic_get_priority(void) {
    return (interrupt_id) gic0.cpu_regs->RUNNING_INT & (0xFU << 4);
}

/// @brief Clears the current interrupt from the GIC.
/// @param id The interrupt ID that caused the last interruption.
void gic_clear_interrupt(interrupt_id id) {
    gic0.cpu_regs->EOI = id;
}

/// @brief TODO
void gic_set_swi(void) {
    gic0.dist_regs->SWI = 0x02000021;
}

/******************************************************************************
 * Static functions' declarations
******************************************************************************/

/// @brief Enables the GIC device. Should be called before attempting to
///     receive any interrupt.
static void gic_enable(void) {
    GIC_PRIORITY_MASK(gic0.cpu_regs->PRI_MASK, 0xF);
    GIC_ENABLE_CPU(gic0.cpu_regs->CPU_CONTROL);
    GIC_ENABLE_DIST(gic0.dist_regs->DIST_CONTROL);
}

#endif // GIC
