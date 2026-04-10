#include <stdint.h>

#define UART_L0      (*(volatile char *)0x5500a000UL)
#define CLK_GATE_REG (*(volatile char *)0x5501200CUL)
#define SOFT_RST_REG (*(volatile char *)0x55012008UL)

void main(){

    // Reset and enable clock
    SOFT_RST_REG |= 1U << 6;
    CLK_GATE_REG |= 1U << 6;

    for (uint8_t i = 0; i < 100; i++); // wait

    // FIXME test without this settings
    *(&UART_L0+8) = 0x07;  // 1b threshold
    *(&UART_L0+16) = 0x20; // Autoflow

    const char * s = "Hello World!\r\n";
    while(*s) {
        UART_L0 = *s;
        s++;
    }
}