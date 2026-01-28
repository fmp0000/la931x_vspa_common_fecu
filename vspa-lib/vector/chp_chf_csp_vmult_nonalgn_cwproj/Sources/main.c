// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

#pragma optimization_level 0

#include <vspa/intrinsics.h>

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "vector.h"

#define L_MAX 31 // number of output DMEM lines

cfloat16_t y[L_MAX * SIZEVEC32] __align_vec;
cfixed16_t x1[L_MAX * SIZEVEC32] __attribute__((section(".ibss")));
cfloat32_t x2[L_MAX * SIZEVEC32] __align_vec __attribute__((section(".ibss")));
cfixed16_t x1n[(L_MAX + 1) * SIZEVEC32] __align_vec; // for non-vec-aligned x1 test
int L = 0;
int nCase = 0;

void main(void) {

    for (int iCase = 0; iCase < nCase; ++iCase) {
        cfixed16_t *px1_src = x1;
        cfixed16_t *px1n_beg = x1n + SIZEVEC32 - 1;
        cfixed16_t *px1n = px1n_beg;
        // copy L lines to x1n (one entry at a time to test non-vec-aligned input)
        for (int k = 0; k < L * SIZEVEC32; ++k) {
            *(px1n++) = *(px1_src++);
        }

        // ===================================================================
        chp_chf_csp_vmult_nonalgn_asm(y, px1n_beg, x2, L);

        __nop();
        __swbreak();
        // ===================================================================
    }

    __nop();
    __swbreak();

    __builtin_done();
}
