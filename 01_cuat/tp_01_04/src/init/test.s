/******************************************************************************
* Headers
******************************************************************************/
.extern startup

/******************************************************************************
* Functions
******************************************************************************/
.text
.global test_alignment_fault
.type test_alignment_fault, %function
test_alignment_fault:
    mov r0, #1
    ldr r0, [r0]
    mov pc, lr

.text
.global test_data_read_fault
.type test_data_read_fault, %function
test_data_read_fault:
    ldr r0, =startup
    ldr r0, [r0]
    mov pc, lr

.text
.global test_data_write_fault
.type test_data_write_fault, %function
test_data_write_fault:
    ldr r0, =startup    // Startup is a kernel function. No RW permissions
    str r0, [r0]
    mov pc, lr

.text
.global test_svc
.type test_svc, %function
test_svc:
    svc #11
    mov pc, lr

.text
.global test_undef
.type test_undef, %function
test_undef:
    .word 0xe7f000f0
    mov pc, lr
