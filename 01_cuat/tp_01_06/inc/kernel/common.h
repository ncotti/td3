#ifndef COMMON_H
#define COMMON_H

#include "op_modes.h"
#include "config.h"
#include "syscalls.h"

/******************************************************************************
 * List of error numbers
******************************************************************************/
#define ERROR_IRQ_INT 200
#define ERROR_UNKNOWN_IRQ 201
#define ERROR_MEMTEST 202

/******************************************************************************
 * Function prototypes
******************************************************************************/

uint32_t get_random(void);
uint32_t __get_random(void);

void critical_error(uint32_t error_code);
void __critical_error(uint32_t error_code);

uint32_t read_privileged_data(uint32_t* addr);
uint32_t __read_privileged_data(uint32_t* addr);

void write_privileged_data(uint32_t* addr, uint32_t value);
void __write_privileged_data(uint32_t* addr, uint32_t value);

extern void __change_saved_op_mode(uint8_t mode);
extern void __memcopy(uint32_t* dst_addr, uint32_t* src_addr, uint32_t size);
extern void __memfill(uint32_t* dst_addr, uint32_t pattern, uint32_t size);

#endif // COMMON_H
