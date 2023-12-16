#ifndef SYSCALLS_H
#define SYSCALLS_H

#include "syscall_id.h"
#include "op_modes.h"
#include "types.h"

/******************************************************************************
 * Assembly syscall functions (the number indicates the amount of parameters)
******************************************************************************/

extern void* syscall0(uint32_t syscall_id);
extern void* syscall1(void* arg1, uint32_t syscall_id);
extern void* syscall2(void* arg1, void* arg2, uint32_t syscall_id);
extern void* syscall3(void* arg1, void* arg2, void* arg3, uint32_t syscall_id);
extern void* syscall4(void* arg1, void* arg2, void* arg3, void* arg4,
    uint32_t syscall_id);
extern void* syscall5(void* arg1, void* arg2, void* arg3, void* arg4,
    void* arg5, uint32_t syscall_id);
extern void* syscall6(void* arg1, void* arg2, void* arg3, void* arg4,
    void* arg5, void* arg6, uint32_t syscall_id);
extern void* syscall7(void* arg1, void* arg2, void* arg3, void* arg4,
     void* arg5, void* arg6, void* arg7, uint32_t syscall_id);

/******************************************************************************
 * Macros used to define syscalls functions
******************************************************************************/

#define PUBLIC_DATA __attribute__((section(".public_data")))
#define SYSCALL_SECTION __attribute__((section(".syscall")))

#define SYSCALL0(syscall_id) \
    syscall0((uint32_t) syscall_id);

#define SYSCALL1(arg1, syscall_id) \
    syscall1((void*) arg1, (uint32_t) syscall_id);

#define SYSCALL2(arg1, arg2, syscall_id) \
    syscall2((void*) arg1, (void*) arg2, (uint32_t) syscall_id);

#define SYSCALL3(arg1, arg2, arg3, syscall_id) \
    syscall3((void*) arg1, (void*) arg2, (void*) arg3, (uint32_t) syscall_id);

#define SYSCALL4(arg1, arg2, arg3, arg4, syscall_id) \
    syscall4((void*) arg1, (void*) arg2, (void*) arg3, (void*) arg4, \
    (uint32_t) syscall_id);

#define SYSCALL5(arg1, arg2, arg3, arg4, arg5, syscall_id) \
    syscall5((void*) arg1, (void*) arg2, (void*) arg3, (void*) arg4, \
    (void*) arg5, (uint32_t) syscall_id);

#define SYSCALL6(arg1, arg2, arg3, arg4, arg5, arg6, syscall_id) \
    syscall6((void*) arg1, (void*) arg2, (void*) arg3, (void*) arg4, \
    (void*) arg5, (void*) arg6, (uint32_t) syscall_id);

#define SYSCALL7(arg1, arg2, arg3, arg4, arg5, arg6, arg7, syscall_id) \
    syscall7((void*) arg1, (void*) arg2, (void*) arg3, (void*) arg4, \
    (void*) arg5, (void*) arg6, (void*) arg7, (uint32_t) syscall_id);

#endif // SYSCALLS_H
