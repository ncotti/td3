/// @brief: Copy a block of memory from a source address to a destination
///     address, given the number of bytes to copy.
/// @param: dst (r0): Destination address (normally VMA).
/// @param: src (r1): Source address (normally LMA).
/// @param: size (r2): Number of bytes of the memory block to copy.
.section .init
.global memcopy
.type memcopy, %function
dst     .req r0
src     .req r1
size    .req r2
buffer  .req r3
memcopy:
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
/// @param size (r2): Number of bytes of the memory block to fill.
.section .init
.global memfill
.type memfill, %function
dst     .req r0
pattern .req r1
size    .req r2
memfill:
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
