// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

#pragma optimization_level 0

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "vector.h"

#define L_MAX 32                              // maximal number of input DMEM lines
#define CBUF_SZ_WORD (3 * (__AU_COUNT__ * 2)) // circular buffer size measured in word.

static cfixed16_t CBUF[CBUF_SZ_WORD] _VSPA_VECTOR_ALIGN;
static cfixed16_t x[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;

static int L = 0;     // actual number of input DMEM lines
static int B = 0;     // number of samples per batch
static int nCase = 0; // number of B values being tested
static float y[L_MAX];

void main(void) {

    // circular buffer test
    for (int iCase = 0; iCase < nCase; ++iCase) {
        cfixed16_t *px_src = x;
        cfixed16_t *pCBUF = CBUF + 1; // test non-vector-aligned input

        int nB = L * (__AU_COUNT__ * 2) / B;
        for (int iB = 0; iB < nB; ++iB) {
            // Copy cfixed16_t samples from px_src to CBUF
            cfixed16_t *tmpDst = pCBUF;
            for (int k = 0; k < B; ++k) {
                *tmpDst = *(px_src++);
                tmpDst = (tmpDst == CBUF + CBUF_SZ_WORD - 1) ? CBUF : tmpDst + 1;
            }

            // ===================================================================
            y[iB] = sumsq(pCBUF, CBUF, B / (__AU_COUNT__ * 2), CBUF_SZ_WORD * 2);
            // ===================================================================

            // Advance the input pointer for next batch
            pCBUF = (pCBUF + B >= CBUF + CBUF_SZ_WORD) ? pCBUF + B - CBUF_SZ_WORD : pCBUF + B;
        }

        __nop();
        __nop();
        __nop();
        __swbreak();
    }

    // linear buffer test
    y[0] = sumsq(x, 2);

    __nop();
    __nop();
    __nop();
    __swbreak();
    __builtin_done();
}
