#ifndef TIMER_H
#define TIMER_H

#include "config.h"

#ifdef TIMER_SP804

#include "types.h"
#include "gic.h"

/******************************************************************************
 * Register definitions
******************************************************************************/
// Base register addresses
#define TIMER0_BASE     ((timer_regs*) 0x10011000)
#define TIMER1_BASE     ((timer_regs*) 0x10011020)
#define TIMER2_BASE     ((timer_regs*) 0x10012000)
#define TIMER3_BASE     ((timer_regs*) 0x10012020)
#define TIMER4_BASE     ((timer_regs*) 0x10018000)
#define TIMER5_BASE     ((timer_regs*) 0x10018020)
#define TIMER6_BASE     ((timer_regs*) 0x10019000)
#define TIMER7_BASE     ((timer_regs*) 0x10019020)

// Register structure for timers.
typedef struct timer_regs {
    reg_t   LOAD;
    reg_t   VALUE;
    reg_t   CONTROL;
    reg_t   INTCLR;
    reg_t   RIS;
    reg_t   MIS;
    reg_t   BGLOAD;
} timer_regs;


/******************************************************************************
 * Device definitions
******************************************************************************/

/// @brief Timer device
typedef struct timer_dev {
    struct timer_regs* regs;    ///< Register map.
    void (*irq_handler)(void);  ///< IRQ handler.
    interrupt_id int_id;        ///< Interrupt ID.
} timer_dev;

extern timer_dev* TIMER0;
extern timer_dev* TIMER1;
extern timer_dev* TIMER2;
extern timer_dev* TIMER3;
extern timer_dev* TIMER4;
extern timer_dev* TIMER5;
extern timer_dev* TIMER6;
extern timer_dev* TIMER7;

/// @brief Operation modes for the timer
typedef enum timer_mode {
    TIMER_MODE_FREE_RUNNING,    ///< Goes from 0xFFFF_FFFF to 0x0000_0000
    TIMER_MODE_ONE_SHOT,        ///< Goes from certain value to 0x0000_0000 and stops
    TIMER_MODE_PERIODIC,        ///< Goes from certain value to 0x0000_0000 and repeats
} timer_mode;


/******************************************************************************
 * Bit operations
******************************************************************************/
// TIMER_CONTROL_REG
#define TIMER_ENABLE(reg)       {reg |= (1U << 7);}
#define TIMER_DISABLE(reg)      {reg &= ~(1U << 7);}
#define TIMER_FREE_RUNNING(reg) {reg |= (1U << 6);}
#define TIMER_PERIODIC(reg)     {reg &= ~(1U << 6);}
#define TIMER_ENABLE_INT(reg)   {reg |= (1U << 5);}
#define TIMER_DISABLE_INT(reg)  {reg &= ~(1U << 5);}
#define TIMER_PRESCALE_1(reg)   {reg &= ~(3U << 2);}
#define TIMER_PRESCALE_4(reg)   {reg &= ~(1U << 3); reg |= (1U << 2);}
#define TIMER_PRESCALE_8(reg)   {reg |= (1U << 3);  reg &= ~(1U << 2);}
#define TIMER_SIZE_32BIT(reg)   {reg |= (1U << 1);}
#define TIMER_SIZE_16BIT(reg)   {reg &= ~(1U << 1);}
#define TIMER_ONE_SHOT(reg)     {reg |= (1U << 0);}
#define TIMER_WRAPPING(reg)     {reg &= ~(1U << 0);}

// TIMER_INTCLR_REG
#define TIMER_CLEAR_INT(reg)    {reg |= (1U << 0);}

/******************************************************************************
* SYSCTRL for the timers
******************************************************************************/
// Register base address for SYSCTRL
#define SYSCTRL0_BASE   ((reg_t*) 0x10001000)
#define SYSCTRL1_BASE   ((reg_t*) 0x1000A000)

// Register operations
#define SYSCTRL_TIMER0_1M(reg) {reg |= (1U << 15);  reg &= ~(1U << 16);}
#define SYSCTRL_TIMER1_1M(reg) {reg |= (1U << 17);  reg &= ~(1U << 18);}
#define SYSCTRL_TIMER2_1M(reg) {reg |= (1U << 19);  reg &= ~(1U << 20);}
#define SYSCTRL_TIMER3_1M(reg) {reg |= (1U << 21);  reg &= ~(1U << 22);}
#define SYSCTRL_TIMER4_1M(reg) {reg |= (1U << 15);  reg &= ~(1U << 16);}
#define SYSCTRL_TIMER5_1M(reg) {reg |= (1U << 17);  reg &= ~(1U << 18);}
#define SYSCTRL_TIMER6_1M(reg) {reg |= (1U << 19);  reg &= ~(1U << 20);}
#define SYSCTRL_TIMER7_1M(reg) {reg |= (1U << 21);  reg &= ~(1U << 22);}

#endif // TIMER_SP804

/******************************************************************************
 * Function prototypes
******************************************************************************/

void timer_init(
        timer_dev* timer,
        uint32_t value,
        timer_mode mode,
        bool interrupt,
        void (*irq_handler)(void));
void timer_resume(timer_dev* timer);
void timer_pause(timer_dev* timer);
void timer_reset(timer_dev* timer);
void timer_load_ms(timer_dev* timer, uint32_t value);
void timer_load_us(timer_dev* timer, uint32_t value);
void timer_set_mode(timer_dev* timer, timer_mode mode);
void timer_enable_interrupt(timer_dev* timer);
void timer_disable_int(timer_dev* timer);
void timer_clear_interrupt(timer_dev* timer);
uint32_t timer_time_ms(timer_dev* timer);
uint32_t timer_time_us(timer_dev* timer);
bool timer_interrupted(timer_dev* timer);

#endif // TIMER_H
