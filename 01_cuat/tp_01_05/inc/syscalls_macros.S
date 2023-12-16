#ifndef SYSCALLS_MACROS_H
#define SYSCALLS_MACROS_H

#include "syscalls.h"
#include "op_modes.h"

// Macro used to execute privileged code in assembly
.macro SYS_ASM syscall
    push {r12, lr}
    svc #100    // SVC_CHANGE_TO_SYSTEM_MODE
    bl \syscall
    cps #0x10    // USR_MODE
    pop {r12, lr}
.endm

#endif // SYSCALLS_MACROS_H
