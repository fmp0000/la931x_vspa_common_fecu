// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// =============================================================================
//! @file           main.c
//! @brief          main function to debug and test
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#pragma optimization_level 0
#include "nco_phase_ramp.h"

// -----------------------------------------------------------------------------
//! @brief          Output buffer.
// -----------------------------------------------------------------------------
cfloat16_t PHASE_RAMP_OUT_BUFF[256] _VSPA_VECTOR_ALIGN;

// -----------------------------------------------------------------------------
//! @brief          Input buffer.
// -----------------------------------------------------------------------------
cfloat32_t gain_cpx;
int32_t phase_ramp;
int32_t phase_init;

void main(void) {
    host_reset();

    // Function call
    phase_ramp_gen(PHASE_RAMP_OUT_BUFF, &gain_cpx, phase_ramp, phase_init, 8);

    __swbreak();
    __done();
}
