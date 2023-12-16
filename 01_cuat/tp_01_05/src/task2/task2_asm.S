#include "task2_ctes.h"

.section .stack, "aw", %nobits
.global task2_stack_top
.space TASK2_STACK_SIZE
.balign 8
task2_stack_top:

.section .reading_area, "aw", %nobits
.global task2_reading_area
task2_reading_area: .space TASK2_READING_AREA_SIZE
