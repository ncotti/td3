#ifndef MMU_H
#define MMU_H
/******************************************************************************
* Page table's constants
******************************************************************************/
#define PAGE_SIZE 0x1000      // 4K
#define PTE2_TOTAL 256

#define TABLE1_SIZE 0x100000  // 1MB
#define TABLE2_SIZE 0x400     // 1KB
// Hardcoded TABLE2_QTTY for section size. 512MB ram equals 512 table2s,
// and add some extra tables for vector table and devices
#define TABLE2_QTTY 550

/******************************************************************************
* App sections variable index
******************************************************************************/
#define SECTION_VMA       0
#define SECTION_SIZE      4
#define SECTION_PA        8
#define SECTION_DOMAIN    12
#define SECTION_AP        13
#define SECTION_MEM       14
#define SECTION_GSX       15
#define SECTION_NEXT      16      // Pointer to the next section

/******************************************************************************
* Arguments used to fill a page table 2 entry.
******************************************************************************/
// Memory access permissions. AP_<privilege_mode>_<user_mode>
// N = No access; R = Read; W = Write
#define AP_N_N    0b000
#define AP_RW_N   0b001
#define AP_RW_R   0b010
#define AP_RW_RW  0b011
#define AP_R_N    0b101
#define AP_R_R    0b111

// Correspond to bits TEX[2:0], C and B, in that order
#define MEM_STRONGLY_ORDERED                  0b00000
#define MEM_SHAREABLE_DEVICE                  0b00001
#define MEM_WRITE_THROUGH_NO_WRITE_ALLOCATE   0b00010
#define MEM_WRITE_BACK_NO_WRITE_ALLOCATE      0b00011
#define MEM_NON_CACHEABLE                     0b00100
#define MEM_WRITE_BACK_WRITE_ALLOCATE         0b00111
#define MEM_NON_SHAREABLE_DEVICE              0b01000

// Correspond to bits nG[11] and S[10]
// G: shared between processes.
// S: accessible by mutiple processors.
// X: executable (can be prefetched and added to the pipeline)
#define G_S_X             0b010
#define G_S_NX            0b011
#define G_NS_X            0b000
#define G_NS_NX           0b001
#define NG_S_X            0b110
#define NG_S_NX           0b111
#define NG_NS_X           0b100
#define NG_NS_NX          0b101

// Domain for the pte1 entry
#define DOMAIN_UNINITIALIZED  0b0000
#define DOMAIN_DEVICE         0b0001
#define DOMAIN_KERNEL         0b0010
#define DOMAIN_RAM_FREE       0b0011
#define DOMAIN_RAM_FULL       0b0100
#define DOMAIN_STACK          0b0101
#define DOMAIN_ROM            0b0110
#define DOMAIN7               0b0111
#define DOMAIN8               0b1000
#define DOMAIN9               0b1001
#define DOMAIN10              0b1010
#define DOMAIN11              0b1011
#define DOMAIN12              0b1100
#define DOMAIN13              0b1101
#define DOMAIN14              0b1110
#define DOMAIN15              0b1111

// If used as the PA of a region, the OS will decide where to load it
#define NO_PA    0x01 // No memory should be at "1"

#endif // MMU_H
