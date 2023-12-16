#ifndef SVC_ID_H
#define SVC_ID_H

/******************************************************************************
 * List of syscall numbers
******************************************************************************/
#define SYSCALL_CRITICAL_ERROR          0
#define SYSCALL_READ_PRIVILEGED_DATA    1
#define SYSCALL_WRITE_PRIVILEGED_DATA   2

#define SYSCALL_GET_RANDOM 10

#define SYSCALL_TESTING0 20
#define SYSCALL_TESTING1 21
#define SYSCALL_TESTING2 22
#define SYSCALL_TESTING3 23
#define SYSCALL_TESTING4 24
#define SYSCALL_TESTING5 25
#define SYSCALL_TESTING6 26
#define SYSCALL_TESTING7 27

#define SYSCALL_TIMER_INIT              30
#define SYSCALL_TIMER_RESUME            31
#define SYSCALL_TIMER_PAUSE             32
#define SYSCALL_TIMER_RESET             33
#define SYSCALL_TIMER_LOAD_MS           34
#define SYSCALL_TIMER_LOAD_US           35
#define SYSCALL_TIMER_SET_MODE          36
#define SYSCALL_TIMER_ENABLE_INTERRUPT  37
#define SYSCALL_TIMER_DISABLE_INT       38
#define SYSCALL_TIMER_CLEAR_INTERRUPT   39
#define SYSCALL_TIMER_TIME_MS           40
#define SYSCALL_TIMER_TIME_US           41
#define SYSCALL_TIMER_INTERRUPTED       42

#define SYSCALL_GIC_ENABLE_INTERRUPT    50
#define SYSCALL_GIC_DISABLE_INTERRUPT   51
#define SYSCALL_GIC_GET_ID              52
#define SYSCALL_GIC_GET_PRIORITY        53
#define SYSCALL_GIC_CLEAR_INTERRUPT     54
#define SYSCALL_GIC_SET_SWI             55

#define SYSCALL_SCHEDULER_INIT          60
#define SYSCALL_SCHEDULER_ADD_TASK      61
#define SYSCALL_SCHEDULER_START         62

#endif // SVC_ID_H
