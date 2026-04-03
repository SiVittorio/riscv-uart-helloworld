OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    SDRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 32K
}

SECTIONS {

    /* Keep binaries lean */
    /DISCARD/ : { *(.riscv.attributes) *(.comment) }

    __stack_pointer$  = ORIGIN(SDRAM) + LENGTH(SDRAM);

    .text : {
        *(.text.init)
        . = 0x200;
        *(.text._start)
        *(.text)
        *(.text.*)
    } > SDRAM

    .data : {
        *(.rodata)
        *(.rodata.*)
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    } > SDRAM

    .bss : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        __bss_end = .;
    } > SDRAM
}
