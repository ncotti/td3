#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "gic.h"
#include "timer.h"
#include "types.h"
#include "op_modes.h"

#define SCHEDULER_MAX_TASKS     10
#define SCHEDULER_TIME_PER_TASK 10000   // [useg]

/******************************************************************************
 * Variable's definitions
******************************************************************************/
typedef struct task_context {
    uint32_t* table1_addr;
    uint32_t spsr;
    uint32_t r0_to_r12[13];
    uint32_t* sp;
    uint32_t* lr;
    void (*pc)(void);
} task_context;

/******************************************************************************
 * Function prototypes
******************************************************************************/

void scheduler_init(void);
uint8_t scheduler_add_task(
    void(*entrypoint)(void),
    uint32_t* stack_top,
    uint32_t* table1_addr);
void scheduler_start (void);
task_context* scheduler_get_current_task_context_addr(void);
task_context* scheduler_get_last_task_context_addr(void);

#endif // SCHEDULER_H