# Cotti OS

Quick explanation of the features, design choices and how to expand this operating system.

## Linker scripts

There is one main linker script in the root folder, called `linker_script.ld`, which includes the linker script for each task.

The kernel and each task are heavily separated inside homonymous folders. This allows for each task to be compiled using the standard sections of the C compiler `.text, .data, .bss`, etc; and then build the task's sections using only the files inside that folder.

Three memory areas area defined:

* **rom**: Where all the data and code is loaded.

* **fixed_ram**: Here, all the identity mapped memory or memory with a fixed physical address is put.

* **free_ram**: This is the memory space used to allocate anything that doesn't have a fixed physical address.

## How the pagination works

Pagination is done by creating a file inside the folder `kernel/sections`. There, a section is defined by the following attributes:

```arm
.word section_vma
.word section_size
.word physical_address  //(this value can be "NO_PA", and is put inside any free ram)
.byte domain
.byte access_permissions
.byte memory_type
.byte global_shareable_executable
```

By labeling the start and end of these sections' definitions, the mmu code can fill all the page tables.

## How to add new tasks

To add a new task, these steps must be followed (most of the files and steps mentioned can be copied from a previous created task, but changing the name from "taskX" to "taskY"):

1. Create a folder called `taskX`, and put there all the code related to the task.

2. Inside that folder, create a linker script to allocate all memory sections related to task. Then, include that file inside the root linker script.

3. Add source folders and include folders inside the Makefile, using the variables `source_dirs` and `header_dirs`. Also, include the linker script in the variable `aux_linker_scripts`.

4. Create a `taskX_sections.S` file inside the folder `kernel/sections`, which must include all sections defined in the linker script create on the step 2 (you can copy another task file, and replace all the instances of "taskX" with "taskY").

5. Copy contents from ROM to RAM, and add the task's entrypoint to the scheduler. To do so, go to the file `kernel/startup.S`, and modify the function `prv_task_init`, adding your task as follows:

```arm
// replace "taskX" with your task
ldr r0, =kernel_sections
ldr r1, =kernel_sections_end
ldr r2, =taskX_table1_addr
bl mmu_fill_page_tables
ldr r0, =hardware_sections
ldr r1, =hardware_sections_end
ldr r2, =taskX_table1_addr
bl mmu_fill_page_tables
ldr r0, =taskX_sections
ldr r1, =taskX_sections_end
ldr r2, =taskX_table1_addr
bl mmu_fill_page_tables

ldr r0, =taskX_table1_addr
WRITE_TTBR0 r0
bl copy_taskX_sections_to_ram
ldr r0, =taskX                  // entrypoint
ldr r1, =taskX_stack_top        // stack top for the task
ldr r2, =taskX_table1_addr
bl scheduler_add_task
```

## How to perform a system test

Inside the file `inc/config.h` you will find several `#define` statements for conditional compiling. The special variable `ENABLE_TESTING` makes the system perform an exhaustive test of all the functionalities of the OS, which are held inside the folder `src/testing`. Therefore, to start a system test you must:

1. Uncomment the line `#define ENABLE_TESTING` in the file `inc/config.h`.

2. Inside the Makefile, change the current gdb_script to `sup/debug_testing.gdb`. This will place breakpoints in relevant parts of the code execution.

## Author

This code was written by Nicolas Gabriel Cotti [ngcotti@gmail.com](ngcotti@gmail.com).
