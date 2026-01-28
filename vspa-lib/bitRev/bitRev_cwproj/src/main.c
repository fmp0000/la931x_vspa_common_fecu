// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           main.c
//! @brief          main function to debug and test bitRev64 IPPU module
// =============================================================================

#pragma optimization_level 0

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "bitRev.h"

// -----------------------------------------------------------------------------
//! @brief          Input buffer.
// -----------------------------------------------------------------------------
vspa_complex_float16 input[1024] _VSPA_VECTOR_ALIGN;

// -----------------------------------------------------------------------------
//! @brief          Output buffer.
// -----------------------------------------------------------------------------
vspa_complex_float16 out[1024] /*__attribute__((section(".idram")))*/ __attribute__((aligned(64)));

unsigned int mask[32] _VSPA_VECTOR_ALIGN;

void main(void) {
    host_clear();

    //   __ip_write(0x1c3, 0x0001FFFF , 0x0);

    if (ippu_is_busy()) {
        __swbreak(); //!< TODO: error on IPPU already busy!
    }

    mask[0] = 4;

    // Function call to IPPU invoke
    bitRevInvoke((vspa_complex_float16 *)(out), (vspa_complex_float16 const *)input, mask);

    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");

    do { /* wait */
    } while (!ippu_is_done());

    __swbreak();

    __done();
}
