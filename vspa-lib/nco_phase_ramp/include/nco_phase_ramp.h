// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           nco_phase_ramp.h
//! @brief          NCO phase ramp generation library interface definitions.
//! @author         NXP Semiconductors.
// =============================================================================

#ifndef __NCO_PHASE_RAMP__
#define __NCO_PHASE_RAMP__

#include "vspa.h"

//! ---------------------------------------------------------------------------
//! @brief        Function to generate a linear phase ramp using NCO:
//!                   x(k) = g * exp(-j * 2 * pi * f / 2^32 * (ki + k))  with k = 0 .. N-1
//!               where:
//!                   g  - complex gain ("gain_cpx")
//!                   f  - phase ramp ("phase_ramp")
//!                   k  - sample index (k = 0 ... (32 * num_lines - 1))
//!                   ki - initial phase term ("phase_init")
//!
//! @param[out]  out_p         Output buffer pointer (complex Half-Precision, DMEM aligned)
//! @param[in]   gain_cpx_p    Complex gain pointer (complex Single-Precision, DMEM non-aligned)
//! @param[in]   phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement)
//! @param[in]   phase_init    Initial phase (signed 32-bit integer, 1's complement)
//! @param[in]   num_lines     Number of output DMEM lines to generate. Each DMEM lines contains 32 output samples.
//!
//! @return      The outut buffer is filled with the phase ramp.
//! @cycle       15 + 2 * num_lines
//! ---------------------------------------------------------------------------
void phase_ramp_gen(cfloat16_t *out_p, cfloat32_t *gain_cpx_p, int32_t phase_ramp, int32_t phase_init, uint32_t num_lines);

#endif // __NCO_PHASE_RAMP__
