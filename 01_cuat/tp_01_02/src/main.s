.global _start
.text
_start:
    nop
    svc #11
    nop
    WFI
    b _start

.data
str: .string "Hello world"

.bss
.space 0x0070
