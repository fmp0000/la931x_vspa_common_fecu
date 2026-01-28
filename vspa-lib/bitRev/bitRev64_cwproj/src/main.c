// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           main.c
//! @brief          main function to debug and test bitRev64 IPPU module
// =============================================================================

#pragma optimization_level 0

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "bitRev.h"

// -----------------------------------------------------------------------------
//! @brief          Input buffer.
// -----------------------------------------------------------------------------
vspa_complex_float16 input[64] __attribute__((aligned(2 * UPHW)));

// -----------------------------------------------------------------------------
//! @brief          Output buffer.
// -----------------------------------------------------------------------------
vspa_complex_float16 out[64] _VSPA_VECTOR_ALIGN;

void main(void) {
    host_clear();

    if (ippu_is_busy()) {
        __swbreak(); //!< TODO: error on IPPU already busy!
    }

    // Function call to IPPU invoke
    bitRev64Invoke((vspa_complex_float16 *)out, (vspa_complex_float16 const *)input);

    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");

    do { /* wait */
    } while (!ippu_is_done());

    __swbreak();

    __done();
}
