// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           freq_domain_corr_c.c
//! @brief          Frequency domain correction C source file
//! @author         NXP Semiconductors.
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>
#include <time.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "freq_domain_corr.h"
#include "nco_phase_ramp.h"

// ---------------------------------------------------------------------------
void freq_domain_corr_64sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                            int32_t phase_init, uint32_t num_streams) {
    // Generate phase ramp with gain, store in scratch
    phase_ramp_gen(scratch_p, gain_cpx_p, phase_ramp, phase_init, FREQ_DOMAIN_CORR_NUM_LINES_64SBC);

    // Apply common phase ramp to all streams
    vec_mult_64chp(scratch_p, inp_p, num_streams);
}

// ---------------------------------------------------------------------------
void freq_domain_corr_128sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams) {
    // Generate phase ramp with gain, store in scratch
    phase_ramp_gen(scratch_p, gain_cpx_p, phase_ramp, phase_init, FREQ_DOMAIN_CORR_NUM_LINES_128SBC);

    // Apply common phase ramp to all streams
    vec_mult_128chp(scratch_p, inp_p, num_streams);
}

// ---------------------------------------------------------------------------
void freq_domain_corr_256sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams) {
    // Generate phase ramp with gain, store in scratch
    phase_ramp_gen(scratch_p, gain_cpx_p, phase_ramp, phase_init, FREQ_DOMAIN_CORR_NUM_LINES_256SBC);

    // Apply common phase ramp to all streams
    vec_mult_256chp(scratch_p, inp_p, num_streams);
}

// ---------------------------------------------------------------------------
void freq_domain_corr_512sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams) {
    // Generate phase ramp with gain, store in scratch
    phase_ramp_gen(scratch_p, gain_cpx_p, phase_ramp, phase_init, FREQ_DOMAIN_CORR_NUM_LINES_512SBC);

    // Apply common phase ramp to all streams
    vec_mult_512chp(scratch_p, inp_p, num_streams);
}

// ---------------------------------------------------------------------------
void freq_domain_corr_1024sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                              int32_t phase_init, uint32_t num_streams) {
    // Generate phase ramp with gain, store in scratch
    phase_ramp_gen(scratch_p, gain_cpx_p, phase_ramp, phase_init, FREQ_DOMAIN_CORR_NUM_LINES_1024SBC);

    // Apply common phase ramp to all streams
    vec_mult_1024chp(scratch_p, inp_p, num_streams);
}
