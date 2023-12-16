#ifndef TASK1_H
#define TASK1_H

#include "types.h"
#include "syscalls.h"
#include "task1_ctes.h"
#include "common.h"

void task1(void);
bool task1_memtest(uint32_t* mem_origin, uint32_t mem_size);

#endif // TASK1_H
