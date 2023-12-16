#ifndef OP_MODES_H
#define OP_MODES_H
/******************************************************************************
* Operation Modes
******************************************************************************/
#define USR_MODE 0x10
#define FIQ_MODE 0x11
#define IRQ_MODE 0x12
#define SVC_MODE 0x13
#define ABT_MODE 0x17
#define UND_MODE 0x1B
#define SYS_MODE 0x1F
#define OP_MODE_BITS 0x1F

#define I_BIT 0x80    // Disable IRQ
#define F_BIT 0x40    // Disable FIQ
#define T_BIT 0x20    // Thumb Mode

#endif // OP_MODES_H
