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
unsigned int llrOut[1024];

__attribute__((aligned(16 * 2 * UPHW))) vspa_complex_fixed16 llrOutHF[512];

__attribute__((aligned(16 * 2 * UPHW))) vspa_complex_float16 qamIn[1024];

__attribute__((aligned(16 * 2 * UPHW))) __fp16 snr_vec[1024];

__attribute__((aligned(16 * 2 * UPHW))) vspa_complex_float16 qamDemodScratch[1536];

// -----------------------------------------------------------------------------
//! @brief          cycles_total
//! @note           stores the cycles measurements results, one entry per block index
// -----------------------------------------------------------------------------
static signed int cycles_total[1];

void main(void) __attribute__((section(".mysection"))) __attribute__((optimize("O0"))) {
    unsigned int NoBits = 1024;
    float SNR = 12.37;

    qamDemodQpskV4(qamIn, snr_vec, llrOutHF, qamDemodScratch, 8);
    __swbreak();

    qamDemodV3_5g(qamIn, snr_vec, llrOut, qamDemodScratch, 8, QAM_BPSK);
    __swbreak();

    qamDemodV3_5g(qamIn, snr_vec, llrOut, qamDemodScratch, 8, QAM_QPSK);
    __swbreak();

    qamDemodV3_5g(qamIn, snr_vec, llrOut, qamDemodScratch, 4, QAM_16);
    __swbreak();

    qamDemodV3_5g(qamIn, snr_vec, llrOut, qamDemodScratch, 4, QAM_64);
    __swbreak();

    qamDemodV3_5g(qamIn, snr_vec, llrOut, qamDemodScratch, 8, QAM_256);
    __swbreak();

    qamDemodQpskNr(qamIn, llrOut, SNR, 4);
    __swbreak();

    qamDemod256Nr(qamIn, llrOut, qamDemodScratch, SNR, 8);
    __swbreak();

    qamDemod256V2(qamIn, llrOut, SNR, 8);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 16, QAM_BPSK);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 8, QAM_QPSK);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 4, QAM_16);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 4, QAM_64);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 4, QAM_256);
    __swbreak();

    qamDemod(qamIn, llrOut, SNR, 4, QAM_1024);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 16, QAM_BPSK);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 8, QAM_QPSK);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 4, QAM_16);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 4, QAM_64);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 4, QAM_256);
    __swbreak();

    qamDemod2Ch(qamIn, llrOut, SNR, 4, QAM_1024);
    __swbreak();
    // Get into low power mode, waiting for Go events:
    __done();
}
