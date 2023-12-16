/*-----------------------------------------------------------------------------
*   @Brief:
*       Copy a block of memory from a source address to a destination address,
*       given the number of bytes to copy.
*
*   @Args:
*       - dst (r0): Destination address (normally VMA).
*       - src (r1): Source address (normally LMA).
*       - size (r2): Number of bytes of the memory block to copy.
*
*   @Return:
*       Void
-----------------------------------------------------------------------------*/
.global memcopy

// Variables
dst .req r0
src .req r1
size .req r2
buffer .req r3

.section .init
memcopy:
    loop:       // Copy each byte into memory
        ldrb buffer, [src], #1
        strb buffer, [dst], #1
        subs size, size, #1
        bne loop
    mov pc, lr

.unreq dst
.unreq src
.unreq size
.unreq buffer
