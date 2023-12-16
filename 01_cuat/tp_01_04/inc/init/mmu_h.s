/// @file mmu_h.s
// Contains all macro and constants defined for the MMU and page tables.

/******************************************************************************
* Headers
******************************************************************************/
// Applications defined in "app_sections" folder
.extern kernel_sections, kernel_sections_end
.extern hardware_sections, hardware_sections_end
.extern app0_sections, app0_sections_end

// Functions
.extern memcopy, memfill

// Linker variables
.extern ld_page_table_vma, ld_page_table_size
.extern ld_ram_origin, ld_ram_length

/******************************************************************************
* Macros for accessing the coprocessor 15 (p15)
******************************************************************************/
.macro READ_TTBR0 reg
    MRC p15, 0, \reg, c2, c0, 0
.endm

.macro WRITE_TTBR0 reg
    MCR p15, 0, \reg, c2, c0, 0
.endm

.macro READ_TTBR1 reg
    MRC p15, 0, \reg, c2, c0, 1
.endm

.macro WRITE_TTBR1 reg
    MCR p15, 0, \reg, c2, c0, 1
.endm

.macro READ_TTBCR reg
    MRC p15, 0, \reg, c2, c0, 2
.endm

.macro WRITE_TTBCR reg
    MCR p15, 0, \reg, c2, c0, 2
.endm

.macro READ_SCTRL reg
    MRC p15, 0, \reg, c1, c0, 0
.endm

.macro WRITE_SCTRL reg
    MCR p15, 0, \reg, c1, c0, 0
.endm

.macro READ_DACR reg
    MRC p15, 0, \reg, c3, c0, 0
.endm

.macro WRITE_DACR reg
    MCR p15, 0, \reg, c3, c0, 0
.endm

.macro READ_DFSR fault, wnr, aux
    MRC p15, 0, \fault, c5, c0, 0
    mov \aux, \fault
    mov \wnr, \fault

    // Get fault number (bits 10, [3:0])
    and \fault, \fault, #0xF
    lsr \aux, \aux, #10
    and \aux, \aux, #1
    orr \fault, \fault, \aux, lsl #4

    // Get WnR (write or read fault) in [11]
    lsr \wnr, \wnr, #11
    and \wnr, \wnr, #1
.endm

.macro READ_DFAR reg
    MRC p15, 0, \reg, c6, c0, 0
.endm

.macro READ_IFSR fault, aux
    MRC p15, 0, \fault, c5, c0, 1
    mov \aux, \fault

    // Get fault number (bits 10, [3:0])
    and \fault, \fault, #0xF
    lsr \aux, \aux, #10
    and \aux, \aux, #1
    orr \fault, \fault, \aux, lsl #4
.endm

.macro READ_IFAR reg
    MRC p15, 0, \reg, c6, c0, 2
.endm

/******************************************************************************
* Macros for accessing bit regions
******************************************************************************/
.macro GET_DOMAIN_FROM_PTE1 domain pte1
    mov \domain, \pte1
    lsr \domain, \domain, #5
    and \domain, \domain, #0xF
.endm

.macro GET_PTE1_INDEX_FROM_VMA pte1_index vma
    lsr \pte1_index, \vma, #20 // first 12 bits
.endm

.macro GET_PTE2_INDEX_FROM_VMA pte2_index vma
    lsr \pte2_index, \vma, #12      // pte2 index in bits [19:12]
    bic \pte2_index, #0xFFFFFF00    // mask 8 LSB.
.endm

.macro GET_TABLE2_ADDR_FROM_PTE1 table2_addr pte1
    mov \table2_addr, \pte1
    bic \table2_addr, \table2_addr, #0xFF     // table2 addr in first 22 bits, put on "0" 10 LSB.
    bic \table2_addr, \table2_addr, #0x300    // Done in separate instructions to be able to use constants.
.endm

/******************************************************************************
* Page table's constants
******************************************************************************/
.equ PAGE_SIZE, 0x1000      // 4K
.equ PTE2_TOTAL, 256

.equ TABLE1_SIZE, 0x100000  // 1MB
.equ TABLE2_SIZE, 0x400     // 1KB
// TODO Hardcoded TABLE2_QTTY for section size
// 512MB ram equals 512 table2s, and add some extra tables for vector table and
// devices
.equ TABLE2_QTTY, 550

/******************************************************************************
* App sections variable index
******************************************************************************/
.equ SECTION_VMA,       0
.equ SECTION_SIZE,      4
.equ SECTION_PA,        8
.equ SECTION_DOMAIN,    12
.equ SECTION_AP,        13
.equ SECTION_MEM,       14
.equ SECTION_GSX,       15
.equ SECTION_NEXT,      16      // Pointer to the next section

/******************************************************************************
* Arguments used to fill a page table 2 entry.
******************************************************************************/
// Memory access permissions. AP_<privilege_mode>_<user_mode>
// N = No access; R = Read; W = Write
.equ AP_N_N,    0b000
.equ AP_RW_N,   0b001
.equ AP_RW_R,   0b010
.equ AP_RW_RW,  0b011
.equ AP_R_N,    0b101
.equ AP_R_R,    0b111

// Correspond to bits TEX[2:0], C and B, in that order
.equ MEM_STRONGLY_ORDERED,                  0b00000
.equ MEM_SHAREABLE_DEVICE,                  0b00001
.equ MEM_WRITE_THROUGH_NO_WRITE_ALLOCATE,   0b00010
.equ MEM_WRITE_BACK_NO_WRITE_ALLOCATE,      0b00011
.equ MEM_NON_CACHEABLE,                     0b00100
.equ MEM_WRITE_BACK_WRITE_ALLOCATE,         0b00111
.equ MEM_NON_SHAREABLE_DEVICE,              0b01000

// Correspond to bits nG[11] and S[10]
// G: shared between processes.
// S: accesible by mutiple processors.
// X: executable (can be prefetched and added to the pipeline)
.equ G_S_X,             0b010
.equ G_S_NX,            0b011
.equ G_NS_X,            0b000
.equ G_NS_NX,           0b001
.equ NG_S_X,            0b110
.equ NG_S_NX,           0b111
.equ NG_NS_X,           0b100
.equ NG_NS_NX,          0b101

// Domain for the pte1 entry
.equ DOMAIN_UNINITIALIZED,  0b0000
.equ DOMAIN_DEVICE,         0b0001
.equ DOMAIN_KERNEL,         0b0010
.equ DOMAIN_RAM_FREE,       0b0011
.equ DOMAIN_RAM_FULL,       0b0100
.equ DOMAIN_STACK,          0b0101
.equ DOMAIN_ROM,            0b0110
.equ DOMAIN7,               0b0111
.equ DOMAIN8,               0b1000
.equ DOMAIN9,               0b1001
.equ DOMAIN10,              0b1010
.equ DOMAIN11,              0b1011
.equ DOMAIN12,              0b1100
.equ DOMAIN13,              0b1101
.equ DOMAIN14,              0b1110
.equ DOMAIN15,              0b1111

// If used as the PA of a region, the OS will decide where to load it
.equ NO_PA,    0x01 // No memory should be at "1"
