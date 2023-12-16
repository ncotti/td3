#ifndef SYSCALLS_H
#define SYSCALLS_H

#include "op_modes.h"

/******************************************************************************
 * Macros used to execute privileged code
******************************************************************************/
// Changes to system mode, executes code, returns to user mode.
#define SYS(syscall) { \
    SVC(SVC_CHANGE_TO_SYSTEM_MODE); \
    syscall; \
    asm volatile("cps %0" :: "i"(USR_MODE)); \
}

// Calls svc with the specific syscall number.
#define SVC(code) {asm volatile("svc %0" :: "i"(code));}

// Same as SVC, but with other syntax.
#define ERROR(error_code) SVC(error_code)


/******************************************************************************
 * List of syscall numbers
******************************************************************************/
#define SVC_CHANGE_TO_SYSTEM_MODE 100
#define SVC_CHANGE_TO_USER_MODE 101
#define SVC_TEST 102

/******************************************************************************
 * List of syscall error numbers
******************************************************************************/
#define ERROR_IRQ_INT 200
#define ERROR_UNKNOWN_IRQ 201
#define ERROR_MEMTEST 202

#endif // SYSCALLS_H
