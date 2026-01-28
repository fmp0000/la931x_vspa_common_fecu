// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file            bitRevIvoke.c
//! @ingroup         GROUP_BITREV
//! @brief           VCPU proxy for bitRev().
//!
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "bitRev.h"

extern uint32_t volatile ippu_args[];

bool bitRevInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn, unsigned int *mask) {
    if (!ippu_is_busy()) {

        // Copy arguments to IPPU data memory:
        ippu_args[0] = (uint32_t)((void *)pOut);
        ippu_args[1] = (uint32_t)((void *)pIn);
        ippu_args[2] = (uint32_t)((void *)mask);

        ippu_arg_base((uint32_t)ippu_args);
        ippu_enable(bitRev, IPPU_PEND_NONE | IPPU_MODE_16BIT); // Start IPPU

        return true;
    }
    return false;
}
