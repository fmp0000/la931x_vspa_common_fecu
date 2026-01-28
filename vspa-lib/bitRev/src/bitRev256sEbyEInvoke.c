// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file            bitRev256sEbyEInvoke.c
//! @ingroup         GROUP_BITREV
//! @brief           VCPU proxy for bitRev256sEbyE().
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

bool bitRev256sEbyEInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn) {
    if (!ippu_is_busy()) {

        // Copy arguments to IPPU data memory:
        ippu_args[0] = (uint32_t)((void *)pOut);
        ippu_args[1] = (uint32_t)((void *)pIn);

        ippu_arg_base((uint32_t)ippu_args);
        ippu_enable(bitRev256sEbyE, IPPU_PEND_NONE | IPPU_MODE_16BIT); // Start IPPU

        return true;
    }
    return false;
}
