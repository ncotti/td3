#ifndef INTERRUPT_CONTROLLER_H
#define INTERRUPT_CONTROLLER_H

#include "config.h"

#ifdef GIC

#include "types.h"

/******************************************************************************
 * Registers
******************************************************************************/

#define GIC0_CPU_BASE       ((gic_cpu_regs*)    0x1E000000)
#define GIC0_DIST_BASE      ((gic_dist_regs*)   0x1E001000)

// CPU register structure
typedef struct gic_cpu_regs {
    reg_t CPU_CONTROL;
    reg_t PRI_MASK;
    reg_t BIN_POINT;
    reg_t INT_ACK;
    reg_t EOI;
    reg_t RUNNING_INT;
    reg_t HPI;
} gic_cpu_regs;

// DISTRIBUTOR register structure
typedef struct gic_dist_regs {
    reg_t DIST_CONTROL;
    reg_t CONTROLLER_TYPE;
    RSVD(0, 0x008, 0x00FC);
    reg_t SET_ENABLE[3];
    RSVD(1, 0x010C, 0x017C);
    reg_t CLEAR_ENABLE[3];
    RSVD(2, 0x018C, 0x01FC);
    reg_t SET_PENDING[3];
    RSVD(3, 0x020C, 0x027C);
    reg_t CLEAR_PENDING[3];
    RSVD(4, 0x028C, 0x02FC);
    reg_t ACTIVE[3];
    RSVD(5, 0x030C, 0x03FC);
    reg_t PRIORITY[24];
    RSVD(6, 0x0460, 0x07FC);
    reg_t CPU_TARGETS[24];
    RSVD(7, 0x0860, 0x0BFC);
    reg_t CONF[6];
    RSVD(8, 0x0C18, 0x0EFC);
    reg_t SWI;
} gic_dist_regs;

/******************************************************************************
 * Device definition
******************************************************************************/

typedef struct gic_dev {
    gic_cpu_regs* cpu_regs;
    gic_dist_regs* dist_regs;
} gic_dev;

/******************************************************************************
 * Register operations
******************************************************************************/

// CPU_CONTROL
#define GIC_ENABLE_CPU(reg)             {reg |= (1U << 0);}
#define GIC_DISABLE_CPU(reg)            {reg &= ~(1U << 0);}

// PRI_MASK
#define GIC_PRIORITY_MASK(reg, value)   {reg = value << 4;}

// DIST_CONTROL
#define GIC_ENABLE_DIST(reg)            {reg |= (1U << 0);}
#define GIC_DISABLE_DIST(reg)           {reg &= ~(1U << 0);}

/******************************************************************************
 * Interrupt IDs
******************************************************************************/

typedef enum interrupt_id {
    INT_TIMER_0_AND_1 = 36,
    INT_TIMER_2_AND_3 = 37,
    INT_TIMER_4_AND_5 = 73,
    INT_TIMER_6_AND_7 = 74,
    INT_ERROR = 1023,
} interrupt_id;

/******************************************************************************
 * Functions' prototypes
******************************************************************************/

void gic_enable_interrupt(interrupt_id id);
void gic_disable_interrupt(interrupt_id id);
interrupt_id gic_get_id(void);
interrupt_id gic_get_priority(void);
void gic_clear_interrupt(interrupt_id id);
void gic_set_swi(void);

#endif // GIC

#endif // INTERRUPT_CONTROLLER_H