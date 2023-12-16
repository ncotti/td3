/******************************************************************************
* Headers
******************************************************************************/
.extern test_data_read_fault, test_data_write_fault, test_alignment_fault
.extern test_svc, test_undef
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
    b main

/******************************************************************************
* Variables
******************************************************************************/
.data
str: .string "Hello world"

.bss
.space 0x0070
