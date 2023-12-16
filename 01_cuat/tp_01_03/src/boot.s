.global _start
.text
_start:
    nop
    svc #11             // SVC interrupt
    nop
    .word 0xe7f000f0    // Invalid instruction, should trigger UNDEF interrupt
    nop

    b main

.data
str: .string "Hello world"

// This address is unaligned
invalid_memory: .word 0x00001112

.global str_inv, str_mem, str_svc
str_inv: .string "INV"
str_mem: .string "MEM"
str_svc: .string "SVC"

.bss
.space 0x0070
