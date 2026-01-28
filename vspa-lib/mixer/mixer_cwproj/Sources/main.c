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
#include "vspa.h"

#include "mixer.h"

#define L 36 // number of input/output DMEM lines. 36 = sum(1..8)
#define NL_CALL \
    8 // number of times mixer being called. First call mixes 1 line, 2nd call mixes 2 lines, ..., 8th call mixes 8 lines.
#define N_FREQ 4 // number of base frequency being tested
#define N_PHAS 7 // number of phase in being tested

static cfixed16_t y[L * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
static cfixed16_t x[L * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;

static uint32_t PhaseIn[N_PHAS], FreqIn[N_FREQ];
static uint32_t PhaseOut1[NL_CALL], PhaseOut2[NL_CALL];

void main(void) {

    for (int iF = 0; iF < N_FREQ; ++iF) {
        for (int iP = 0; iP < N_PHAS; ++iP) {

            // ===================================================================

            // not-in-place
            uint32_t idx = 0;
            uint32_t phase = PhaseIn[iP];
            for (int iL = 0; iL < NL_CALL; ++iL) {
                PhaseOut1[iL] = mixer_asm(&y[idx], &x[idx], phase, FreqIn[iF], iL + 1);

                // next call
                phase = PhaseOut1[iL];
                idx += (iL + 1) * (__AU_COUNT__ * 2);
            }

            // in-place
            idx = 0;
            phase = PhaseIn[iP];
            for (int iL = 0; iL < NL_CALL; ++iL) {
                PhaseOut2[iL] = mixer_asm(&x[idx], &x[idx], phase, FreqIn[iF], iL + 1);

                // next call
                phase = PhaseOut2[iL];
                idx += (iL + 1) * (__AU_COUNT__ * 2);
            }

            __nop();
            __swbreak();
            // ===================================================================
        }
    }

    __nop();
    __swbreak();

    __builtin_done();
}
