#include "scheduler.h"
#include "syscalls.h"
#include "timer.h"

/// @brief Main function.
/// @return "0" on success. Anything else on error.
int main(void) {
    scheduler_start();
}
