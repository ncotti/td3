#include "task1_ctes.h"

.section .stack, "aw", %nobits
.global task1_stack_top
.space TASK1_STACK_SIZE
.balign 8
task1_stack_top:

.section .reading_area, "aw", %nobits
.global task1_reading_area
task1_reading_area: .space TASK1_READING_AREA_SIZE
