// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2018 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @author         NXP Semiconductors.
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "cycShiftFD.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
struct {
    uint32_t shift;
    uint32_t out_len;
} TEST_CTRL;

#define TEST_MAX_LEN 2048

// ----------------------------------------------------------------------------
//! @brief   TCL synchronization function.
// ----------------------------------------------------------------------------
void TCL_SYNC(void);
void TCL_SYNC(void) __attribute__((noinline)) { return; }

// ----------------------------------------------------------------------------
//! @brief   Memory utilities function.
// ----------------------------------------------------------------------------
/* Flush pipeline */
void pipe_flush() __attribute__((optimize("O0"))) {
    __asm("fnop;");
    __asm("fnop;");
    __asm("fnop;");
}

// ----------------------------------------------------------------------------
//! @brief  Tester input buffers.
// ----------------------------------------------------------------------------
static cfloat16_t INP_BUFF[TEST_MAX_LEN] _VSPA_VECTOR_ALIGN;
static cfloat16_t OUT_BUFF[TEST_MAX_LEN] _VSPA_VECTOR_ALIGN __attribute__((section(".ibss")));

// ----------------------------------------------------------------------------
//! @brief          Main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) __attribute__((optimize("O0"))) {

    while (1) {
        cycShiftFD_asm(INP_BUFF, OUT_BUFF, TEST_CTRL.shift, TEST_CTRL.out_len);
        pipe_flush();
        TCL_SYNC();
    }
    __asm("fnop;");
    __asm("fnop;");
    __swbreak();
    __builtin_done();
}
