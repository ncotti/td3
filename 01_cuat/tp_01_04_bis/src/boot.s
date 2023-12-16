/******************************************************************************
* Headers
******************************************************************************/
.extern test_data_read_fault, test_data_write_fault, test_alignment_fault
.extern test_svc, test_undef, test_table_walk_fault
.extern main

/******************************************************************************
* Functions
******************************************************************************/
.text
.type _start, %function
.global _start
_start:
    //bl test_svc
    //bl test_undef
    //bl test_data_read_fault
    //bl test_data_write_fault
    //bl test_alignment_fault
    loop_table_walk_fault:
        bl test_table_walk_fault
    b loop_table_walk_fault
    ldr r0, =str
    b main


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

/******************************************************************************
* Variables
******************************************************************************/
.data
str: .string "Hello world"  // Not used
// If this values are odd, they will produce alignment faults instead
w_random_seed_times:  .word 314159260
w_random_seed_plus:   .word 0x1234560
w_random_number:      .word 0

.bss
.space 0x0070
