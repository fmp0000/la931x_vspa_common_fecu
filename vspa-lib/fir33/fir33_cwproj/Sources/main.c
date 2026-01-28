// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "fir.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
fixed16_t taps_buffer[256] __align_vec;
cfixed16_t x_buffer[2048 + 128] __align_vec;
cfixed16_t y_buffer[2048] __align_vec __attribute__((section(".ibss")));
unsigned int config_buffer[4];

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int datSz, tapsSz, datIter, tapsIter, type, inOffset;

    host_reset();

    datSz = config_buffer[0];
    tapsSz = config_buffer[1];
    type = config_buffer[2];
    inOffset = config_buffer[3];

    if (type == 0) {
        // REAL, HALF-FIXED
        datIter = datSz >> 6;   /* %64 */
        tapsIter = tapsSz - 11; /* nb tap should be >11 */

        firFilterReal(x_buffer + inOffset, y_buffer, taps_buffer, datIter, tapsIter);
    }

    __swbreak();
    __builtin_done();
}
