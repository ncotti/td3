.include "mmu_h.s"

/******************************************************************************
* Local variables
******************************************************************************/
.section .init_data, "aw", %progbits
w_table2_qtty:      .word 0
w_ram_used_pages:   .word 0

/******************************************************************************
* Global functions
******************************************************************************/
/// @brief: Initialize mmu.
.section .init
.global mmu_init
.type mmu_init, %function
table1_addr .req    r4
mmu_init:
    push {r4, lr}
    // Clear table section
    ldr r0, =ld_page_table_vma
    mov r1, #0x00
    ldr r2, =ld_page_table_size
    bl memfill

    // Write origin of table1 to p15 registers
    ldr table1_addr, =app0_table1_addr
    WRITE_TTBR1 table1_addr
    WRITE_TTBR0 table1_addr

    // Configure TTBCR, N = 0, always use TTBCR0
    READ_TTBCR r0
    mov r1, #0b111
    bic r0, r0, r1
    WRITE_TTBCR r0

    // All domains will check against its access permissions
    ldr r0, =0x55555555
    WRITE_DACR r0

    // Fill kernel page tables
    ldr r0, =kernel_sections
    ldr r1, =kernel_sections_end
    mov r2, table1_addr
    bl mmu_fill_page_tables
    ldr r0, =hardware_sections
    ldr r1, =hardware_sections_end
    mov r2, table1_addr
    bl mmu_fill_page_tables
    ldr r0, =app0_sections
    ldr r1, =app0_sections_end
    mov r2, table1_addr
    bl mmu_fill_page_tables

    // Configure MMU
    READ_SCTRL r0
    mov r1, #0x01
    bic r0, r0, r1, lsl #30   // Exceptions in ARM state
    bic r0, r0, r1, lsl #29   // Access flag disabled
    bic r0, r0, r1, lsl #28   // TEX remap disabled.
    orr r0, r0, r1, lsl #1    // Alignment fault enabled
    orr r0, r0, r1, lsl #0    // Enable MMU

    WRITE_SCTRL r0
    DSB
    ISB
    pop {r4, lr}
    mov pc, lr

.unreq table1_addr

/// @brief Creates an fills entries for the page table 1 (pt1) and 2 (pt2),
///     pointed by the content of register TTBR0.
///     To do so, the OS needs the base VMA of each section defined in the
///     linker script, its size and properties.
/// @param r0 (section_addr):
///     Address of the start of the app's sections.
/// @param r1 (section_end_addr):
///     Address of the end of the app's sections.
/// @param r2 (table1_addr):
///     Address of the page table 1 that the user wants to fill.
.section .init
.type mmu_fill_page_tables, %function
.global mmu_fill_page_tables
buffer                  .req r0
section_end_addr        .req r1
table2_qtty             .req r2
section_size            .req r3
section_addr            .req r4
table1_addr             .req r5
pte1                    .req r6
table2_addr             .req r7
pte2                    .req r8
pte1_index              .req r9
pte2_index              .req r10
section_pages_counter   .req r11
mmu_fill_page_tables:
    push {r4-r11, r12, lr}
    mov section_addr, r0    // I need "r0" to be free
    mov table1_addr, r2     // I need "r2" to be free
    loop_section_addr:
        // For each section
        mov section_pages_counter, #0
        ldr section_size, [section_addr, #SECTION_SIZE]
        ldr pte1_index, [section_addr, #SECTION_VMA]
        GET_PTE1_INDEX_FROM_VMA pte1_index pte1_index
        ldr pte2_index, [section_addr, #SECTION_VMA]
        GET_PTE2_INDEX_FROM_VMA pte2_index pte2_index

        loop_fill_pte1:
            // Fill all the neccesary pte1s
            ldr pte1, [table1_addr, pte1_index, lsl #2]

            // Check if the pte1 is empty
            teq pte1, #0
            bne pte1_exists

            pte1_doesnt_exits:
                // Get the address of a newly created page table2
                ldr buffer, =w_table2_qtty
                ldr table2_qtty, [buffer]
                mov table2_addr, table1_addr
                add table2_addr, table2_addr, #TABLE1_SIZE
                add table2_addr, table2_addr, table2_qtty, lsl #10 // each table2 has a size of 2^10 = 1K

                // Add 1 to the amount of tables2 and store
                add table2_qtty, table2_qtty, #1
                str table2_qtty, [buffer]

                // Fill pte1
                push {r0-r3}
                mov r0, table2_addr                         // table2_addr
                ldrb r1, [section_addr, #SECTION_DOMAIN]    // Domain
                add r2, table1_addr, pte1_index, lsl #2     // pte1 addr
                bl mmu_fill_pte1
                pop {r0-r3}
                b loop_fill_table2

            pte1_exists:
                GET_TABLE2_ADDR_FROM_PTE1 table2_addr pte1

            loop_fill_table2:
                // For each pte2, fill its contents
                push {r0-r3}
                add r0, table2_addr, pte2_index, lsl #2 // Fifth parameter, pte2 address
                push {r0, r12}
                ldr r0, [section_addr, #SECTION_PA]
                teq r0, #NO_PA                          // Check if the OS can choose the PA, or is fixed
                bleq mmu_assign_free_pa
                movne r1, section_pages_counter
                blne mmu_assign_fixed_pa
                ldrb r1, [section_addr, #SECTION_AP]
                ldrb r2, [section_addr, #SECTION_MEM]
                ldrb r3, [section_addr, #SECTION_GSX]
                bl mmu_fill_pte2
                pop {r0, r12}
                pop {r0-r3}

                // Repeat until the section size is greater than 0, and the
                // pte2_index is less than the total amount of pte2s.
                add section_pages_counter, section_pages_counter, #1
                subs section_size, #PAGE_SIZE
                ble next_section
                adds pte2_index, pte2_index, #1
                cmp pte2_index, #PTE2_TOTAL
                moveq pte2_index, #0
                blt loop_fill_table2

        // Repeat for each pte1 entry
        add pte1_index, pte1_index, #1
        b loop_fill_pte1

    next_section:
        // Check if there is another section
        adds section_addr, section_addr, #SECTION_NEXT
        cmp section_addr, section_end_addr
        blt loop_section_addr

    pop {r4-r11, r12, lr}
    mov pc, lr

.unreq buffer
.unreq section_end_addr
.unreq table2_qtty
.unreq section_size
.unreq section_addr
.unreq table1_addr
.unreq pte1
.unreq table2_addr
.unreq pte2
.unreq pte1_index
.unreq pte2_index
.unreq section_pages_counter

/// @brief: Fill a page table1 entry.
/// @param r0 (table2_addr): base address of the table2, will fill the pte1
/// @param r1 (domain): domain for the table2 base address.
/// @param r2 (pte1_addr): address of the pte1.
/// @return r0: pte1 entry content.
.section .init
.global mmu_fill_pte1
.type mmu_fill_pte1, %function
pte1        .req r0      // Same as table2_addr
domain      .req r1
pte1_addr   .req r2
mmu_fill_pte1:
    // pte1 has first 22 bits with table2_addr, and the rest has parameters
    mov r3, #0x3FF  // Clear first 10 bits
    bic pte1, r3
    orr pte1, pte1, domain, lsl #5  // Fill domain
    orr pte1, pte1, #0x1  // Always 1, indicates page table2 base address
    str pte1, [pte1_addr]   // Store pte1 in the address
    mov pc, lr

.unreq pte1
.unreq domain
.unreq pte1_addr

/// @brief: Complete a page table 2 entry.
/// @param r0 (PA): Physical address for the page (LSB 12 bits should be "0")
/// @param r1 (AP): Memory type (use .equ MEM_x).
/// @param r2 (MEM): Access permissions (use .equ AP_x).
/// @param r3 (GSX): Global, shareable, executable (use .equ xG_xS_xX).
/// @param r4 (pte2_addr): Where the entry will be loaded.
.section .init
.type mmu_fill_pte2, %function
.global mmu_fill_pte2
pte2    .req r0 // Same as PA.
ap      .req r1
mem     .req r2
gsx     .req r3
mmu_fill_pte2:
    push {r4, r12}
    mov r4, #0xFFF                  // Clear 12 LSB.
    bic pte2, r4

    mov r4, gsx                     // Remove X, get only G and S
    lsr r4, r4, #1
    orr pte2, pte2, r4, lsl #10     // nG and S bit

    mov r4, ap                      // Get only AP[2]
    and r4, r4, #0b100
    orr pte2, pte2, r4, lsl #9      // AP[2]

    mov r4, mem                     // Get only TEX[2:0], remove C and B
    and r4, r4, #0b11100
    orr pte2, pte2, r4, lsl #6      // TEX[2:0]

    mov r4, ap                      // Get only AP[1:0], remove AP[2]
    and r4, r4, #0b011
    orr pte2, pte2, r4, lsl #4      // AP[1:0]

    mov r4, mem                     // Get only C and B, remove TEX[2:0]
    and r4, r4, #0b00011
    orr pte2, pte2, r4, lsl #2      // C and B bit

    orr pte2, pte2, #0b10           // lsl #1, Always 1

    mov r4, gsx                     // Remove G and S, get X
    and r4, r4, #0b001
    orr pte2, pte2, r4, lsl #0      // XN bit
    pop {r4, r12}

    ldr r1, [sp]                    // "pte2_addr" argument
    str pte2, [r1]
    mov pc, lr

.unreq pte2
.unreq mem
.unreq ap
.unreq gsx

/// @brief: Assings a free physical address to a page. A variable has the
///     amount of pages already used inside the RAM space, and this function
///     increments by 1 that variable and returns the equivalent memory address.
///     It does not check for unused ram, or ram overflow.
/// @return r0: a free PA to fill a pte2 entry.
.section .init
.type mmu_assign_free_pa, %function
.global mmu_assign_free_pa
pa                  .req r0
ram_used_pages      .req r1
addr_ram_used_pages .req r2
mmu_assign_free_pa:
    ldr addr_ram_used_pages, =w_ram_used_pages
    ldr ram_used_pages, [addr_ram_used_pages]
    ldr pa, =ld_ram_origin
    add pa, pa, ram_used_pages, lsl #12 // Move the address 4K
    add ram_used_pages, ram_used_pages, #1
    str ram_used_pages, [addr_ram_used_pages]
    mov pc, lr

.unreq pa
.unreq ram_used_pages
.unreq addr_ram_used_pages

/// @brief: Given a section with a fixed physical address and a size greater
///     than 4KB, this function adds 4KB to the PA to fill the memory.
/// @param r0 (pa): Fixed physical address.
/// @param r1 (page_number): How many pages has the section used
/// @return r0: pa + page_number * PAGE_SIZE.
.section .init
.type mmu_assign_fixed_pa, %function
.global mmu_assign_fixed_pa
pa          .req r0
page_number .req r1
mmu_assign_fixed_pa:
    mov r2, #PAGE_SIZE
    mul r3, page_number, r2 // Use r3 for assembler warning
    add pa, pa, r3
    mov pc, lr

.unreq pa
.unreq page_number
