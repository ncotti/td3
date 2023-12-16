/******************************************************************************
* @brief:
*   Copy a block of memory from a source address to a destination address,
*   given the number of bytes to copy.
*
* @param:
*   - dst (r0): Destination address (normally VMA).
*   - src (r1): Source address (normally LMA).
*   - size (r2): Number of bytes of the memory block to copy.
*
* @return:
*   Void
******************************************************************************/
.global memcopy
.section .init
dst     .req r0
src     .req r1
size    .req r2
buffer  .req r3
memcopy:
    loop_memcopy:       // Copy each byte into memory
        ldrb buffer, [src], #1
        strb buffer, [dst], #1
        subs size, size, #1
        bne loop_memcopy
    mov pc, lr

.unreq dst
.unreq src
.unreq size
.unreq buffer

/******************************************************************************
* @brief:
*   Fill a memory address with an 8 bit pattern.
*
* @param:
*   - dst (r0): Destination address.
*   - pattern (r1): The 8 LSB bits will be used to fill the memory space.
*   - size (r2): Number of bytes of the memory block to fill.
*
* @return:
*   Void
******************************************************************************/
.global memfill
.section .init
dst     .req r0
pattern .req r1
size    .req r2
memfill:
    loop_memfill:
        strb pattern, [dst], #1
        subs size, size, #1
        bne loop_memfill
    mov pc, lr

.unreq dst
.unreq pattern
.unreq size

