.global _start

.extern ld_stack_origin
.extern ld_text_section_lma, ld_text_section_vma, ld_text_section_size
.extern ld_data_section_origin, ld_data_section_vma, ld_data_section_size
.extern memcopy

.section .init
_start:
    ldr sp, =ld_stack_origin            // Initialice stack pointer

    ldr r0, =ld_text_section_vma        // Load memcopy args
    ldr r1, =ld_text_section_lma
    ldr r2, =ld_text_section_size
    bl memcopy

    ldr r0, =ld_data_section_vma
    ldr r1, =ld_data_section_lma
    ldr r2, =ld_data_section_size
    bl memcopy

    b end

.text
end:        // Actual code
    nop
    nop
    nop

.data
str: .string "Hola mundo"
