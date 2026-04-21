OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  SDRAM (rwx) : ORIGIN = 0x20000000, LENGTH = 32K
}

STACK_SIZE = 512;

CL_SIZE = 32;

SECTIONS {

    /* Keep binaries lean */
    /DISCARD/ : { *(.riscv.attributes) *(.comment) }

    __global_pointer$ = ADDR(.misc) + SIZEOF(.misc) / 2;
    __stack_pointer$  = ORIGIN(SDRAM) + LENGTH(SDRAM) - 8;


    .text : {
    *(.text.init)
    . = 0x200;
    *(.text._start)
    *(.text)
    *(.text.*)
    } > SDRAM

    .misc ALIGN(32) : {
        *(.rodata)
        *(.rodata.*)
        *(.data)
        *(.data.*)
        *(.srodata)
        *(.srodata.*)
        *(.sdata)
        *(.sdata.*)
    } > SDRAM

    .bss ALIGN(32) : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        __bss_end = .;
    } > SDRAM

    .bulk ALIGN(32) : {
        *(.bulk)
        *(.bulk.*)
    } > SDRAM

}
