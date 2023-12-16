#ifndef INT_HANDLERS_H
#define INT_HANDLERS_H

#include "timer.h"
#include "gic.h"
#include "syscalls.h"
#include "op_modes.h"
#include "config.h"
#include "test_codes.h"
#include "common.h"

#define IRQ_DONT_SWITCH_CONTEXT 1
#define RETURN_TO_SAME 0
#define RETURN_TO_NEXT 1

/******************************************************************************
* Instruction Fetch faults (IFSR)
******************************************************************************/

typedef enum instruction_fault {
    IF_TABLE1_EXTERNAL_ABORT   =   0b01100,
    IF_TABLE2_EXTERNAL_ABORT   =   0b01110,
    IF_TABLE1_PARITY_ERROR     =   0b11100,
    IF_TABLE2_PARITY_ERROR     =   0b11110,
    IF_SECTION_TRANSLATION     =   0b00101,
    IF_PAGE_TRANSLATION        =   0b00111,
    IF_ACCESS_FLAG_SECTION     =   0b00011,
    IF_ACCESS_FLAG_PAGE        =   0b00110,
    IF_DOMAIN_SECTION          =   0b01001,
    IF_DOMAIN_PAGE             =   0b01011,
    IF_PERMISSION_SECTION      =   0b01101,
    IF_PERMISSION_PAGE         =   0b01111,
} instruction_fault;


/******************************************************************************
* Data Fetch faults (DFSR)
******************************************************************************/

typedef enum data_fault {
    DF_ALIGNMENT               =   0b00001,
    DF_CACHE_MAINTENANCE       =   0b00100,
    DF_TABLE1_EXTERNAL_ABORT   =   0b01100,
    DF_TABLE2_EXTERNAL_ABORT   =   0b01110,
    DF_TABLE1_PARITY_ERROR     =   0b11100,
    DF_TABLE2_PARITY_ERROR     =   0b11110,
    DF_SECTION_TRANSLATION     =   0b00101,
    DF_PAGE_TRANSLATION        =   0b00111,
    DF_ACCESS_FLAG_SECTION     =   0b00011,
    DF_ACCESS_FLAG_PAGE        =   0b00110,
    DF_DOMAIN_SECTION          =   0b01001,
    DF_DOMAIN_PAGE             =   0b01011,
    DF_PERMISSION_SECTION      =   0b01101,
    DF_PERMISSION_PAGE         =   0b01111,
} data_fault;

typedef enum rw_fault {
    READ_ACCESS = 0,
    WRITE_ACCESS = 1,
} rw_fault;

/******************************************************************************
 * Function prototypes
******************************************************************************/

uint8_t pref_handler(instruction_fault fault, uint32_t* addr);
uint8_t abt_handler(data_fault fault, uint32_t* addr, rw_fault rw);
uint8_t irq_handler(void);
extern void mmu_fill_pte_from_vma(uint32_t* vma);

extern uint32_t und_return;
extern uint32_t pref_return;
extern uint32_t abt_return;
extern uint32_t irq_return;

#endif // INT_HANDLERS_H
