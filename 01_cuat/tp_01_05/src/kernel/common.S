#include "op_modes.h"
#include "config.h"
#include "test_codes.h"

/// @brief Generate a pseudo-random number, following the formula:
///   w_random_number = w_random_seed_times * w_random_number + w_random_seed_plus
.text
.global random
.type random, %function
random_number       .req r0
multiplication      .req r1
addition            .req r1
buffer              .req r2
random_number_addr  .req r3
random:
    ldr random_number_addr, =w_random_number
    ldr buffer, [random_number_addr]
    ldr multiplication, =w_random_seed_times
    ldr multiplication, [multiplication]
    mul random_number, buffer, multiplication
    ldr addition, =w_random_seed_plus
    ldr addition, [addition]
    add random_number, random_number, addition
    str random_number, [random_number_addr]
    mov pc, lr

.unreq random_number
.unreq multiplication
.unreq addition
.unreq buffer
.unreq random_number_addr

.data
// If this values are odd, they will produce alignment faults instead
w_random_seed_times:  .word 314159260
w_random_seed_plus:   .word 0x1234560
w_random_number:      .word 0

/// @brief Changes the operation mode in the SPSR register.
/// @param (r0): OP_MODE
.text
.type change_saved_op_mode, %function
.global change_saved_op_mode
change_saved_op_mode:
    mrs r1, spsr
    bic r1, #OP_MODE_BITS
    orr r1, r1, r0
    msr spsr, r1
    mov pc, lr

#ifdef ENABLE_TESTING
/// @brief This function is used for testing syscalls. Only the kernel should
///   be able to access this function.
.text
.type privileged_kernel_function, %function
.global privileged_kernel_function
privileged_kernel_function:
    mov r0, #TESTING_KERNEL_FUNCTION
    mov pc, lr


.data
.global privileged_kernel_data
privileged_kernel_data: .word TESTING_KERNEL_DATA
#endif