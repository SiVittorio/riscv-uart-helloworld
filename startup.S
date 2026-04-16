// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

.section .text._start

// Minimal CRT0
.global _start
.align 4
_start:
    // Globally disable Machine and Supervisor interrupts
    csrrc x0, mstatus, 10

    // Park SMP harts
    csrr t0, mhartid
    beqz t0, 2f
1:
    wfi
    j 1b
2:
    // Init stack and global pointer iff linked as nonzero
    mv t1, sp
    la t0, __stack_pointer$
    beqz t0, 1f
    mv sp, t0
1:  .option push
    .option norelax
    la t0, __global_pointer$
    beqz t0, 1f
    mv gp, t0
1:  .option pop

    // Store existing stack, global, return pointers on new stack
    addi sp, sp, -24
    sd t1, 0(sp)
    sd gp, 8(sp)
    sd ra, 16(sp)

    // Zero the .bss section
    la t0, __bss_start      // t0 = bss start address
    la t1, __bss_end        // t1 = bss end address
    sub t2, t1, t0          // t2 = #bytes to zero
    li a0, 0

_zero_bss_loop:
    addi t4, t2, -32
    blez t2, _fp_init           // t2 <= 0? => No bss to zero
    blt t4, x0, _zero_bss_rem   // t4 <  0? => Less than 4 words left
    sd a0, 0(t0)
    sd a0, 8(t0)
    sd a0, 16(t0)
    sd a0, 24(t0)
    addi t2, t2, -32
    addi t0, t0, 32
    bgt t2, x0, _zero_bss_loop  // Still more to go
    j _fp_init

_zero_bss_rem:
    sb a0, 0(t0)
    addi t2, t2, -1
    addi t0, t0, 1
    bgt t2, x0, _zero_bss_rem

_fp_init:
    // Set FS state to "Initial", enabling FP instructions
    li t1, 1
    slli t1, t1, 13
    csrs mstatus, t1

    // Set FS state to "Clean"
    csrrc x0, mstatus, t1

    //////////// Switch to supervisor mode start /////////////////
    // Machine and Supervisor External Interrupt enable
    # li      t1, 0xA03
    # csrw    mie, t1 # enable ext interrupts
    # li      t1, 0x800 
    # csrw    mstatus, t1 # enable supervisor mode interrupts

    # auipc ra, 0
    # addi ra, ra, 0xE
    # csrw mepc, ra # set return address to fence command
    # mret # switch

    //////////// Switch to supervisor mode end /////////////////

    # enable ext and software machine interrupts
    li      t1, 0xA00
    csrw    mie, t1
    # Stores the state of the machine mode interrupts
    li      t1, 0x8
    csrw    mstatus, t1

    // Full fence, then jump to main
    fence
    call main
    