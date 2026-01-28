///*************************************************************************
// Copyright 2014 Freescale Semiconductor Inc.
// All Rights Reserved
//
// This is unpublished proprietary source code of Freescale Semiconductor Inc.
// The copyright notice above does not evidence any actual or intended
// publication of such source code.
//
// This code may only be used and executed on Freescale products or
// simulated Freescale products.
// This code comes without any warranty. Do not distribute without approval.
//**************************************************************************

    .section    .init
    .global     _start
    .type       _start, @function
_start:
    mv          sp, __stack;    // Initialize stack pointer.
    set.creg      4, 0;         // Disable condition code update.
    set.creg     12, 0;         // Disable H capture and increment.
    set.creg     16, 0;         // Reset fractional interpolation numerator.
    set.creg     17, 0;         // Reset fractional interpolation denominator
    set.creg     18, 0;         // Reset fractional interpolation phase.
    set.creg     20, 0;         // AU output lane [4095:0] in single-precision mode.
    set.creg    255, 0;         // Real mode, full data path, normal AU output.
    mv          a19, 0;        // To disable modulo addressing.
    
    jmp         _main;          // Jump to C entry-point.
    set.range   a2, a19, 0;    // Disable modulo addressing.
    set.range   a3, a19, 0;    // Disable modulo addressing.
    done;

    .size _start, .-_start
