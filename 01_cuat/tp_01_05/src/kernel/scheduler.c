#include "scheduler.h"

extern uint32_t kernel_table1_addr;
extern uint32_t stack_idle_task;

/******************************************************************************
 * Static variables
******************************************************************************/
// Current task being executed (or current task to be executed)
static int32_t prv_current_task = 0;

// Last task that was executed
static int32_t prv_last_task = 0;

// Holds all the scheduler tasks contexts
static task_context prv_task_contexts[SCHEDULER_MAX_TASKS];

/******************************************************************************
 * Static functions prototypes
******************************************************************************/

static void prv_idle_task(void);
static void prv_scheduler_change_task (void);

/******************************************************************************
 * Functions declarations
******************************************************************************/
/// @brief Initializes the scheduler with the default task in thumb mode.
void scheduler_init(void) {
    uint8_t i;
    for (i = 0; i < SCHEDULER_MAX_TASKS; i++) {
        // The IRQ executes the following instruction (+4 either ARM or Thumb)
        prv_task_contexts[i].pc = prv_idle_task + 4;
        prv_task_contexts[i].spsr = SYS_MODE | T_BIT;
        prv_task_contexts[i].sp = &stack_idle_task;
        prv_task_contexts[i].table1_addr = &kernel_table1_addr;
    }
}

/// @brief Adds a task to be executed by the scheduler. Tasks should never end.
/// @param task Function pointer to the task main loop.
/// @param mode Either THUMB or ARM, the code execution.
/// @return "0" on success, "1" if the scheduler is full.
uint8_t scheduler_add_task(
        void(*entrypoint)(void),
        uint32_t* stack_top,
        uint32_t* table1_addr) {
    uint8_t i = 0;
    for (i = 0; i < SCHEDULER_MAX_TASKS; i++) {
        if (prv_task_contexts[i].pc == prv_idle_task + 4) {
            // Tasks are called from the IRQ
            prv_task_contexts[i].pc = entrypoint + 4;
            if ((uint32_t) entrypoint % 2 == 1) {
                prv_task_contexts[i].spsr = USR_MODE | T_BIT;
            } else {
                prv_task_contexts[i].spsr = USR_MODE;
            }
            prv_task_contexts[i].sp = stack_top;
            prv_task_contexts[i].table1_addr = table1_addr;
            return 0;
        }
    }
    return 1;
}

/// @brief Start the scheduler. Functions should have been added beforehand.
void scheduler_start (void) {
    timer_init(TIMER0, SCHEDULER_TIME_PER_TASK, TIMER_MODE_PERIODIC, TRUE, prv_scheduler_change_task);
    gic_set_swi();   // The first context switch occurs in the IRQ_handler
    prv_idle_task();
}

/// @brief Returns the current task context address.
task_context* scheduler_get_current_task_context_addr(void) {
    return &(prv_task_contexts[prv_current_task]);
}

/// @brief Returns the last task context address.
task_context* scheduler_get_last_task_context_addr(void) {
    return &(prv_task_contexts[prv_last_task]);
}


/******************************************************************************
 * Static functions
******************************************************************************/
/// @brief Change to next task in the "tasks" array. This function is called
///   with the IRQ of the timer.
static void prv_scheduler_change_task (void) {
    timer_clear_interrupt(TIMER0);
    prv_last_task = prv_current_task;
    prv_current_task++;
    if (prv_current_task == SCHEDULER_MAX_TASKS) {
        prv_current_task = 0;
    }
}

/// @brief Empty task, used to fill the scheduler
static void prv_idle_task(void) {
    while(1) {
        asm("nop");
        asm("WFI");
    }
}
