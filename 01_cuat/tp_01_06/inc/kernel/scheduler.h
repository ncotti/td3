#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "config.h"
#include "gic.h"
#include "timer.h"
#include "types.h"
#include "op_modes.h"
#include "syscalls.h"
#ifdef ENABLE_NEON
#include <arm_neon.h>
extern void neon_disable(void);
#endif

#define SCHEDULER_MAX_TASKS     10
#define SCHEDULER_TIME_PER_TASK 10000   // [useg]

/******************************************************************************
 * Variable's definitions
******************************************************************************/
typedef struct task_context {
    uint32_t* table1_addr;
    uint32_t asid;
    uint32_t spsr;
    uint32_t r0_to_r12[13];
    uint32_t* sp;
    uint32_t* lr;
    void (*pc)(void);
    #ifdef ENABLE_NEON
    uint32_t fpscr;
    uint32x4_t q[16];
    #endif
} task_context;

/******************************************************************************
 * Function prototypes
******************************************************************************/

void scheduler_init(void);
void __scheduler_init(void);

uint8_t scheduler_add_task( void(*entrypoint)(void),
    uint32_t* stack_top, uint32_t* table1_addr);
uint8_t __scheduler_add_task( void(*entrypoint)(void),
    uint32_t* stack_top, uint32_t* table1_addr);

void scheduler_start (void);
void __scheduler_start (void);

task_context* __scheduler_get_current_task_context_addr(void);
task_context* __scheduler_get_last_task_context_addr(void);

#endif // SCHEDULER_H