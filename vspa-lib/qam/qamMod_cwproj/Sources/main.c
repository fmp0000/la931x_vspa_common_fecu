// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025 copy  NXP Semiconductors

// =============================================================================
//! @file           main.c
//! @brief          main function to debug & test fdTapGen function
//! @copyright      &copy; 2016 NXP Semiconductors
// =============================================================================

#include <vspa/intrinsics.h>

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "qam.h"

// =============================================================================
// Local data:
// =============================================================================

// -----------------------------------------------------------------------------
//! @brief          output buffer.
// -----------------------------------------------------------------------------
_VSPA_VECTOR_ALIGN
unsigned int bitIn[320];

_VSPA_VECTOR_ALIGN
vspa_complex_float16 qamOut[1056];

// -----------------------------------------------------------------------------
//! @brief          cycles_total
//! @note           stores the cycles measurements results, one entry per block index
// -----------------------------------------------------------------------------
static signed int cycles_total[1];

void main(void) __attribute__((section(".mysection"))) __attribute__((optimize("O0"))) {
    unsigned int NoBits = 1024;

    qamMod(bitIn, qamOut, NoBits >> 5, QAM_BPSK);
    __swbreak();

    qamMod(bitIn, qamOut, NoBits >> 6, QAM_QPSK);
    __swbreak();

    qamMod(bitIn, qamOut, NoBits >> 7, QAM_16);
    __swbreak();

    qamMod(bitIn, qamOut, NoBits >> 8, QAM_256);
    __swbreak();

    qamMod(bitIn, qamOut, 32, QAM_64);
    __swbreak();

    qamMod(bitIn, qamOut, 32, QAM_1024);
    __swbreak();

    // Get into low power mode, waiting for Go events:
    __done();
}
