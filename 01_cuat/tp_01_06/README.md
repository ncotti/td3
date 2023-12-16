# Cotti OS

Quick explanation of the features, design choices and how to expand this operating system.

## Install

This example was compiled using [GCC-Linaro 7.5-2019.12](https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/). The default GCC-Linaro binary provided in the Ubuntu binaries does not work:

```bash
$ sudo apt show gcc-arm-linux-gnueabihf
Package: gcc-arm-linux-gnueabihf
Version: 4:11.2.0-1ubuntu1
Priority: optional
Section: devel
Source: gcc-defaults (1.193ubuntu1)
Origin: Ubuntu
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Original-Maintainer: Debian GCC Maintainers <debian-gcc@lists.debian.org>
Bugs: https://bugs.launchpad.net/ubuntu/+filebug
Installed-Size: 25,6 kB
Depends: cpp-arm-linux-gnueabihf (= 4:11.2.0-1ubuntu1), gcc-11-arm-linux-gnueabihf (>= 11.2.0-1~)
Recommends: libc6-dev-armhf-cross | libc-dev-armhf-cross
Suggests: make, manpages-dev, autoconf, automake, libtool, flex, bison, gdb-arm-linux-gnueabihf, gcc-doc
Download-Size: 1.242 B
APT-Sources: http://ar.archive.ubuntu.com/ubuntu jammy/main amd64 Packages
Description: GNU C compiler for the armhf architecture
 This is the GNU C compiler, a fairly portable optimizing compiler for C.
 .
 This is a dependency package providing the default GNU C cross-compiler
 for the armhf architecture.
```

## Execution

Inside the folder, there is a Makefile. Running `make` will present you a help menu with all possible options to be executed. The most relevant are `make debug`, which compiles the program, runs QEMU, and starts a debugging client, and `make headers`, which generates a lot of information about the binaries.

```txt
$ make
    binary     Generate binary file, without ELF headers.
    clean      Erase contents of build directory.
    clear      Same as clean.
    compile    Compile all source code, generate ELF file.
    dasm       Generate disassemble for all object files and elf file.
    debug      Debug the program (no need to "make run" first, compile with "-g")
    docs       Generate doxygen documentation as HTML
    headers    Generate symbol table and section headers for all object files.
    help       Display this message.
    kill       Stop qemu process running on background
    run        Execute compiled program (using QEMU)
```

The debugging client is an instance of *gdb-multiarch* from the terminal. A *gdb script* is already provided with useful breakpoints and metadata, the most common commands that you'll need are:

```c
c               // Continue until next breakpoint
n               // Next instruction, without entering function calls
s               // Step, entering function calls
b <file>:<n>    // Create a breakpoint in file <file> in line number <n>
b <foo>         // Create breakpoint at start of function <foo>
d <n>           // Delete breakpoint number <n>.
```

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
bl __scheduler_add_task
```

## Syscalls

Syscalls were implemented following the arm/EABI described in the Linux Programmer's Manual:

```bash
$ man syscall 2

Arch/ABI    Instruction         System  Ret  Ret  Error
                                call #  val  val2
───────────────────────────────────────────────────────
arm/EABI    swi 0x0               r7    r0   r1    -

Arch/ABI      arg1  arg2  arg3  arg4  arg5  arg6  arg7  Notes
──────────────────────────────────────────────────────────────
arm/EABI      r0    r1    r2    r3    r4    r5    r6
```

What this says is that all syscalls should be invoked using `svc #0`, the syscall number should be stored in `r7`, arguments up to seven should go from `r0` to `r6`, and the return value should go in `r0-r1`.

When changing from user mode to supervisor mode, the stack pointer changes; therefore, more than 4 arguments can't be passed directly through the stack. Instead, they must be passed through the registers, and then stored in the supervisor's stack.

To define a syscalls, a lot of extra steps must be made to ensure correct behavior. In this section I'll explain briefly how to define a new syscall, and why some decisions were made.

### How to define a syscall

1. First, a normal C function must be created. The only requisite is that its name starts with a double underscore, to indicate that it's a privileged function defined by the kernel, and only usable by it.

    ```c
    uint32_t __my_syscall(uint32_t arg1, uint32_t arg2) {
        /* Do something */
    }
    ```

2. Create a twin function with the same return type and parameters, but following this rules:
    * Its name should be the same one as the previous function, but without the leading underscores.

    * At the start of the declaration, the macro `SYSCALL_SECTION` should be used. This will compile the function inside a memory section accessible by the user called `.syscall`.

    * For the body of the function, the macro `SYSCALL<X>` should be used, where `<X>` must be replaced with the amount of parameters the syscall was defined with. Pass the arguments of the function in the same order as they were declared, and add as a final argument a "SYSCALL_ID".

    ```c
    /// All documentation should be added to this function, as this is the one seen by the user.
    SYSCALL_SECTION uint32_t my_syscall(uint32_t arg1, uint32_t arg2) {
        SYSCALL2(arg1, arg2, SYSCALL_MY_SYSCALL_ID);
    }
    ```

3. Inside the file `inc/kernel/syscall_id.h`, add a number representing your syscall id. The preferred name for this id is: `SYSCALL_<function_name>`

    ```c
    #define SYSCALL_MY_SYSCALL 3
    ```

4. Inside the file `src/kernel/syscalls.S`, add the function name declared in step 1 (the one with leading underscores), to the syscall table, in the exact same position used as its ID.

    ```arm
    .data
    .global syscall_table
    syscall_table:
    // 0
    .word __critical_error
    .word __read_privileged_data
    .word __write_privileged_data
    .word __my_syscall     // SYSCALL_MY_SYSCALL = 3
    .word __no_syscall
    .word __no_syscall
    .word __no_syscall
    .word __no_syscall
    .word __no_syscall
    .word __no_syscall

    // 10
    .word __get_random
    .word __no_syscall
    .word __no_syscall
    ```

5. If needed, a variable defined in the kernel can be made public adding the macro `PUBLIC_DATA` before it's declaration. This will put the variable inside the section `.public_data`, which is accessible by the user.

    ```c
    PUBLIC_DATA uint32_t some_data = 0;
    ```

### Explaining the macro SYSCALL\<X\>

The macro `SYSCALL<X>` calls a namesake function defined in assembler, casting all the arguments to a `(void*)`. The syscall functions all do the same: store registers `r4-r7`, load the arguments in those registers, and then call `svc #0`. Since each function a different amount of parameters, each syscall function handles them differently.

### Explaining the syscall ID and syscall table

The syscall table is an array of function pointers, and the syscall ID is used as the offset. By default, all the function pointers inside the syscall table point to the `__no_syscall` function, which block operation. That's why the function name must be added in the position defined by the syscall id, because that's the function that will be called inside the SVC_handler.

## How to perform a system test

Inside the file `inc/config.h` you will find several `#define` statements for conditional compiling. The special variable `ENABLE_TESTING` makes the system perform an exhaustive test of all the functionalities of the OS, which are held inside the folder `src/testing`. Therefore, to start a system test you must:

1. Uncomment the line `#define ENABLE_TESTING` in the file `inc/config.h`.

2. Inside the Makefile, change the current gdb_script to `sup/debug_testing.gdb`. This will place breakpoints in relevant parts of the code execution.

## Author

This code was written by Nicolas Gabriel Cotti [ngcotti@gmail.com](ngcotti@gmail.com).
