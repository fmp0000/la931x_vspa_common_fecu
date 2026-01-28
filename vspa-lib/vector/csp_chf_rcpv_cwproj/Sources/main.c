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

static vspa_complex_float32 y[L_MAX * (__AU_COUNT__ * 2)] __attribute__((section(".ibss")));
static cfixed16_t x[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
static int L = 0;
static int nCase = 0;

// extern vspa2_complex_float16 rcpv_scratch[];

void main(void) {

    for (int iCase = 0; iCase < nCase; ++iCase) {
        // ===================================================================
        rcpv(y, x, L);

        __nop();
        __swbreak();
        // ===================================================================
    }

    __nop();
    __swbreak();

    __builtin_done();
}
