// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          FD_QEC library tester source file.
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

#include "fd_qec.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
struct FD_QEC_TEST_T {
    uint32_t inpLen; // Sequence length  (468,216, 104)
} FD_QEC_TEST_CTRL;

/* Maximum buffer sizes*/
#define MAX_SIZE_IN 4096 * 4

/* Maximum buffer sizes*/
#define MAX_SIZE_OUT 4096

// ----------------------------------------------------------------------------
//! @brief   Timer variables and definitions.
// ----------------------------------------------------------------------------
clock_t clk_start, clk_end, clk_overhead, clk_cycles;
#define CLOCK_INIT()                        \
    {                                       \
        clk_start = clock();                \
        clk_end = clock();                  \
        clk_overhead = clk_end - clk_start; \
    }
#define CLOCK_START() \
    { clk_start = clock(); }
#define CLOCK_STOP()                                     \
    {                                                    \
        clk_end = clock();                               \
        clk_cycles = clk_end - clk_start - clk_overhead; \
    }

// ----------------------------------------------------------------------------
//! @brief   TCL synchronization function.
// ----------------------------------------------------------------------------
void TCL_SYNC(void);
void TCL_SYNC(void) __attribute__((noinline)) { return; }

// ----------------------------------------------------------------------------
//! @brief   Memcopy function.
// ----------------------------------------------------------------------------
void mem_set(void *ptr, uint16_t value, size_t num) __attribute__((optimize("O0"))) {
    uint32_t idx;
    for (idx = 0; idx < num; idx++) {
        *((uint16_t *)ptr)++ = value;
    }
}

/* Flush pipeline */
void pipe_flush() __attribute__((optimize("O0"))) {
    __asm("fnop;");
    __asm("fnop;");
    __asm("fnop;");
}

// ----------------------------------------------------------------------------
//! @brief  Tester input/output buffer used to emulate producer of cyclic shift
//!         input data and consumer of decimator output data.
//! FORINT  Ignore these buffers for integration.
// ----------------------------------------------------------------------------
static cfixed16_t FD_QEC_INP_BUFF[MAX_SIZE_IN] _VSPA_VECTOR_ALIGN;
static cfixed16_t FD_QEC_OUT_BUFF[MAX_SIZE_OUT] _VSPA_VECTOR_ALIGN;

void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t input_len;

    /* Init clock */
    CLOCK_INIT();

    while (1) {

        /* Testcase parameters */
        input_len = FD_QEC_TEST_CTRL.inpLen;
        CLOCK_START();
        fd_qec(FD_QEC_OUT_BUFF, FD_QEC_INP_BUFF, FD_QEC_INP_BUFF + input_len, FD_QEC_INP_BUFF + (input_len * 2), input_len);

        FD_QEC_TEST_CTRL.inpLen = FD_QEC_TEST_CTRL.inpLen * 2;
        CLOCK_STOP();
        pipe_flush();

        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
