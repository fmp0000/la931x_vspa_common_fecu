// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           decimator_alloc.c
//! @brief          DECIMATOR library source file.
//! @author         NXP Semiconductors.
//! @ingroup        GROUP_DECIM
//!
//! The decimator_alloc.c allocates required memory buffers for DECIMATOR library.
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>
#include <time.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "decimator.h"

// -----------------------------------------------------------------------------
//! @brief      Filter buffer which holds the filter coefficients.The filter coefficients
//!             are assumed REAL and the filter length given by {@link DECIM_FLT_LEN}
//!             is assumed EVEN and between the values (including) {@link DECIM_MIN_FLT_LEN}
//!             and {@link DECIM_MAX_FLT_LEN}.
//! @attention  The filter coefficients are placed in this buffer in the inversed
//!             order as opposed to their natural order.
// -----------------------------------------------------------------------------
const uint32_t DECIM_FLT_BUFF[DECIM_FLT_LEN] _VSPA_VECTOR_ALIGN = {
#include "decimator_filter.txt"
};

// -----------------------------------------------------------------------------
//! @brief      Scratch memory for 4x Decimator which holds the data
//!             of the intermediate stage (the output of first 2x decimator).
//! @attention  The integrator can reuse this memory between kernel calls.
// -----------------------------------------------------------------------------
cfixed16_t DECIM_4X_SCRATCH_MEM[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE * DECIM_FACT_2X] _VSPA_VECTOR_ALIGN;

// -----------------------------------------------------------------------------
//! @brief      Scratch memory for 8x Decimator which holds the data
//!             of the intermediate stages (the output of first and second 2x decimator).
//! @attention  The integrator can reuse this memory between kernel calls.
// -----------------------------------------------------------------------------
cfixed16_t DECIM_8X_SCRATCH_MEM[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE * DECIM_FACT_4X] _VSPA_VECTOR_ALIGN;
