// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          DFT tester source file
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

#include "dft.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------

#define HALF_FIXED 0
#define HALF_FLOAT 1
#define SINGLE_PRECISION 2
#define DOUBLE_PRECISION 3

struct TEST_CTRL_T {
    uint32_t n_dft;
    uint32_t inp_prec;
    uint32_t out_prec;
} TEST_CTRL;

#define MAX_LEN 512

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
cfixed16_t INP_BUFF[2 * MAX_LEN] _VSPA_VECTOR_ALIGN;
cfloat32_t SCRATCH_DFT_BUFF[2 * MAX_LEN] __align_vec __attribute__((section(".ibss")));
cfloat16_t OUT_BUFF[2 * MAX_LEN] _VSPA_VECTOR_ALIGN;

// ----------------------------------------------------------------------------
//! @brief          Main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t inpPrec, outPrec;
    /* Init clock */
    CLOCK_INIT();

    while (1) {
        inpPrec = TEST_CTRL.inp_prec;
        outPrec = TEST_CTRL.out_prec;

        if (TEST_CTRL.n_dft > 96) {

            if ((inpPrec == HALF_FIXED) && (outPrec == HALF_FLOAT)) {
                CLOCK_START();
                dft_hfx_hfl_asm(INP_BUFF, SCRATCH_DFT_BUFF, OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();
            } else if ((inpPrec == SINGLE_PRECISION) && (outPrec == HALF_FLOAT)) {
                CLOCK_START();
                dft_sfl_hfl_asm((cfloat32_t *)INP_BUFF, SCRATCH_DFT_BUFF, OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();

            } else if ((inpPrec == HALF_FIXED) && (outPrec == SINGLE_PRECISION)) {
                CLOCK_START();
                dft_hfx_sfl_asm(INP_BUFF, (cfloat32_t *)OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();

            } else if ((inpPrec == SINGLE_PRECISION) && (outPrec == SINGLE_PRECISION)) {
                CLOCK_START();
                dft_sfl_sfl_asm((cfloat32_t *)INP_BUFF, (cfloat32_t *)OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();
            }

        } else {
            if ((inpPrec == HALF_FIXED) && (outPrec == HALF_FLOAT)) {
                CLOCK_START();
                mini_dft_hfx_hfl_asm(INP_BUFF, OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();
            } else if ((inpPrec == SINGLE_PRECISION) && (outPrec == HALF_FLOAT)) {
                CLOCK_START();
                mini_dft_sfl_hfl_asm((cfloat32_t *)INP_BUFF, OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();

            } else if ((inpPrec == HALF_FIXED) && (outPrec == SINGLE_PRECISION)) {
                CLOCK_START();
                mini_dft_hfx_sfl_asm(INP_BUFF, (cfloat32_t *)OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();

            } else if ((inpPrec == SINGLE_PRECISION) && (outPrec == SINGLE_PRECISION)) {
                CLOCK_START();
                mini_dft_sfl_sfl_asm((cfloat32_t *)INP_BUFF, (cfloat32_t *)OUT_BUFF, TEST_CTRL.n_dft);
                CLOCK_STOP();
            }
        }

        pipe_flush();
        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
