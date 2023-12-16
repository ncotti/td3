/// @file hardware_sections.s
/// This file holds all sections defined for the hardware devices,
/// which are meant to be included by all other tasks that require them.
#include "mmu.h"

/******************************************************************************
* Hardware devices
******************************************************************************/
.section .rodata
.global hardware_sections
.global hardware_sections_end
hardware_sections:
// GIC0
.word 0x1E000000            // Initial VA
.word 0x10000       // 64K  // Size of the section
.word 0x1E000000            // Physical Address (can be NO_PA if not needed)
.byte DOMAIN_DEVICE         // Domain
.byte AP_RW_RW              // Access permissions
.byte MEM_SHAREABLE_DEVICE  // Memory type
.byte G_S_NX                // Global, shareable, executable

// SYSCTRL0
.word 0x10001000
.word 0x1000        // 4K
.word 0x10001000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX

// SYSCTRL1
.word 0x1001A000
.word 0x1000        // 4K
.word 0x1001A000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX

// TIMER0_AND_1
.word 0x10011000
.word 0x1000        // 4K
.word 0x10011000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX

// TIMER2_AND_3
.word 0x10012000
.word 0x1000        // 4K
.word 0x10012000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX

// TIMER4_AND_5
.word 0x10018000
.word 0x1000        // 4K
.word 0x10018000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX

// TIMER6_AND_7
.word 0x10019000
.word 0x1000        // 4K
.word 0x10019000
.byte DOMAIN_DEVICE
.byte AP_RW_RW
.byte MEM_SHAREABLE_DEVICE
.byte G_S_NX
hardware_sections_end:
