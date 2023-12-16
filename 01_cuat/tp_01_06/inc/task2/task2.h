#ifndef TASK2_H
#define TASK2_H

#include "types.h"
#include "syscalls.h"
#include "task2_ctes.h"
#include "common.h"

void task2(void);
bool task2_memtest(uint32_t* mem_origin, uint32_t mem_size);

#endif // TASK2_H
