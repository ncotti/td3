#ifndef CONFIG_H
#define CONFIG_H

/******************************************************************************
 * Hardware devices
******************************************************************************/
#define TIMER_SP804
#define GIC

/******************************************************************************
 * System configuration
******************************************************************************/
// If enabled, a complete system test will be executed instead of the
// main function
//#define ENABLE_TESTING

#ifdef ENABLE_TESTING
    // If enabled, the scheduler will be tested as well.
    #define ENABLE_TEST_SCHEDULER
#endif

// If enabled, a section fault or a page fault from the MMU will be mapped onto
// a free RAM space, without regard for the cause
//#define ENABLE_MEMORY_MAPPING_FROM_ABORT

// If enabled, NEON instructions will be usable.
#define ENABLE_NEON

#endif // CONFIG_H
