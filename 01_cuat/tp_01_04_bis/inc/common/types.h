#ifndef TYPES_H
#define TYPES_H

#include <stdint.h>

// Register type (must be volatile).
typedef volatile uint32_t reg_t;

// Bool Type
typedef enum bool {
    FALSE = 0,
    TRUE = 1,
} bool;

// Function that does nothing
void no_handler(void);
#define NO_HANDLER no_handler

// Used to create placebo memory spaces in register structs.
#define RSVD(name,from,to) uint8_t _reserved_##name[ to - from + 1 ];

#endif // TYPES_H