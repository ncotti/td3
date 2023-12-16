/*-----------------------------------------------------------------------------
*   @Brief:
*       Fill a memory address with an 8 bit pattern.
*
*   @Args:
*       - dst (r0): Destination address.
*       - pattern (r1): The 8 LSB bits will be used to fill the memory space.
*       - size (r2): Number of bytes of the memory block to fill.
*
*   @Return:
*       Void
-----------------------------------------------------------------------------*/
.global memfill

// Variables
dst     .req r0
pattern .req r1
size    .req r2

.section .init
memfill:
    loop:
        strb pattern, [dst], #1
        subs size, size, #1
        bne loop
    mov pc, lr

.unreq dst
.unreq pattern
.unreq size
