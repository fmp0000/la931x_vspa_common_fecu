// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2018 - 2025   NXP Semiconductors

// =============================================================================
//! @file           main.c
//! @brief          main function to debug and test mat_by_vec VCPU module
// =============================================================================

#pragma optimization_level 0

#include <vspa/intrinsics.h>

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>
#include <time.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "vspa.h"

#include "mat_by_vec.h"

// -----------------------------------------------------------------------------
//! @brief          Output buffer.
// -----------------------------------------------------------------------------
vspa_complex_fixed16 py1[256] __align_vec;  // min size = 32 * L
vspa_complex_fixed16 py2[256] __align_vec;  // min size = 32 * L
vspa_complex_fixed16 py3[256] __align_vec;  // min size = 32 * L
vspa_complex_fixed16 py4[256] __align_vec;  // min size = 32 * L
vspa_complex_fixed16 py5[256] __align_vec;  // min size = 32 * L
vspa_complex_float16 py6[256] __align_vec;  // min size = 32 * L
vspa_complex_float16 py7[256] __align_vec;  // min size = 32 * L
vspa_complex_float16 py8[256] __align_vec;  // min size = 32 * L
vspa_complex_float16 py9[256] __align_vec;  // min size = 32 * L
vspa_complex_float16 py10[256] __align_vec; // min size = 32 * L

// -----------------------------------------------------------------------------
//! @brief           Input buffer.
// -----------------------------------------------------------------------------
vspa_complex_fixed16 const px[22000] __align_vec; // min size = M*offset
vspa_complex_fixed16 const pa_chfx[128];          // min size = M
vspa_complex_float16 const pa_chfl[128];          // min size = M
fixed16_t const pa_rhfx[128];                     // min size = M
float16_t const pa_rhfl[128];                     // min size = M
float const pa_rfl[128];                          // min size = M
uint32_t offset;
uint32_t L;
uint32_t M;
void main(void) {
    host_reset();

    // Function call
    mat_by_vec_chfx_chfx_chfx(py1, px, pa_chfx, offset, L, M);

    mat_by_vec_chfx_chfx_chfl(py2, px, pa_chfl, offset, L, M);

    mat_by_vec_chfx_chfx_rhfx(py3, px, pa_rhfx, offset, L, M);

    mat_by_vec_chfx_chfx_rhfl(py4, px, pa_rhfl, offset, L, M);

    mat_by_vec_chfx_chfx_rfl(py5, px, pa_rfl, offset, L, M);

    mat_by_vec_chfl_chfx_chfx(py6, px, pa_chfx, offset, L, M);

    mat_by_vec_chfl_chfx_chfl(py7, px, pa_chfl, offset, L, M);

    mat_by_vec_chfl_chfx_rhfx(py8, px, pa_rhfx, offset, L, M);

    mat_by_vec_chfl_chfx_rhfl(py9, px, pa_rhfl, offset, L, M);

    mat_by_vec_chfl_chfx_rfl(py10, px, pa_rfl, offset, L, M);

    __swbreak();

    __done();
}
