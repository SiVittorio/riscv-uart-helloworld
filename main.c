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

    // Cant use rodata secton in ld-script
    // FIXME
    UART_L0 = 'H';
    UART_L0 = 'e';
    UART_L0 = 'l';
    UART_L0 = 'l';
    UART_L0 = 'o';
    UART_L0 = ' ';
    UART_L0 = 'w';
    UART_L0 = 'o';
    UART_L0 = 'r';
    UART_L0 = 'l';
    UART_L0 = 'd';
    UART_L0 = '!';
    
}