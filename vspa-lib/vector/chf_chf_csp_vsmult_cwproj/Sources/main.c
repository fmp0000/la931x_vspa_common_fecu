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

#include "vector2.h"

// cfloat16_t y[4096]  _VSPA_VECTOR_ALIGN;
// cfloat16_t x1[4096]  __align_vec __attribute__(( section(".ibss") ));
cfloat16_t y[2048] _VSPA_VECTOR_ALIGN;
cfloat16_t x1[2048] __align_vec __attribute__((section(".ibss")));
vspa_complex_float32 a[1] _VSPA_VECTOR_ALIGN;
unsigned int config_buffer[4];

void main(void) {
    size_t n_lines, offset;

    host_reset();

    n_lines = config_buffer[0];
    offset = config_buffer[1];

    if ((n_lines & 0x1F) == 0)
        n_lines = n_lines >> 6;
    else
        n_lines = (n_lines >> 6) + 1;

    chp_chp_csp_vMultiSclr(y, x1 + offset, a, n_lines);

    __nop();
    __swbreak();

    __builtin_done();
}
