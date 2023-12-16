#include "op_modes.h"

/// @brief: Copy a block of memory from a source address to a destination
///     address, given the number of bytes to copy.
/// @param: dst (r0): Destination address (normally VMA).
/// @param: src (r1): Source address (normally LMA).
/// @param: size (r2): Number of bytes of the memory block to copy.
.section .init
.global __memcopy
.type __memcopy, %function
dst     .req r0
src     .req r1
size    .req r2
buffer  .req r3
__memcopy:
    cmp size, #0
    ble memcopy_end
    loop_memcopy:       // Copy each byte into memory
        ldrb buffer, [src], #1
        strb buffer, [dst], #1
        subs size, size, #1
        bne loop_memcopy
    memcopy_end:
        mov pc, lr

.unreq dst
.unreq src
.unreq size
.unreq buffer

/// @brief: Fill a memory address with an 8 bit pattern.
/// @param: dst (r0): Destination address.
/// @param: pattern (r1): The 8 LSB bits will be used to fill the memory space.
/// @param: size (r2): Number of bytes of the memory block to fill.
.section .init
.global __memfill
.type __memfill, %function
dst     .req r0
pattern .req r1
size    .req r2
__memfill:
    cmp size, #0
    ble memfill_end
    loop_memfill:
        strb pattern, [dst], #1
        subs size, size, #1
        bne loop_memfill
    memfill_end:
        mov pc, lr

.unreq dst
.unreq pattern
.unreq size

/// @brief Changes the operation mode in the SPSR register.
/// @param (r0): OP_MODE
.text
.type __change_saved_op_mode, %function
.global __change_saved_op_mode
__change_saved_op_mode:
    mrs r1, spsr
    bic r1, #OP_MODE_BITS
    orr r1, r1, r0
    msr spsr, r1
    mov pc, lr