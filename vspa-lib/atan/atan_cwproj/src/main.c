// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          Atan library tester source file.
//! @author         NXP Semiconductors.
// =============================================================================

#include "vcpu.h"

#include "atan.h"
#include <time.h>

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
#define HF16 0
#define HP16 1
#define SP32 2

struct ATAN_TEST_CTRL_T {
    uint32_t inputLen; // Input length (samples)
    uint32_t inpPrec;  // Input  precision (0/1) for Half Fixed / Single Precision
    uint32_t outPrec;  // Output precision (0/1) for Half Fixed / Single Precision
} ATAN_TEST_CTRL;

#define ATAN_TEST_MAX_LEN 256

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
//! @brief  Tester input buffers.
// ----------------------------------------------------------------------------
static cfloat32_t ATAN_INP_BUFF[ATAN_TEST_MAX_LEN];
static float ATAN_OUT_BUFF[ATAN_TEST_MAX_LEN] _VSPA_VECTOR_ALIGN;

// ----------------------------------------------------------------------------
//! @brief          Atan main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t count;

    /* Init clock */
    CLOCK_INIT();

    while (1) {
        /* Testcase parameters */
        count = ATAN_TEST_CTRL.inputLen / 64;

        /* Clear output buffer */
        mem_set(ATAN_OUT_BUFF, 0xFFFF, sizeof(ATAN_OUT_BUFF));

        /* Clear VRA context */
        __set_creg(19, 0);
        __set_creg(3, 0);

        if ((HF16 == ATAN_TEST_CTRL.inpPrec) && (HF16 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_chf_hf_asm((cfixed16_t *)ATAN_INP_BUFF, (fixed16_t *)ATAN_OUT_BUFF, count);
            CLOCK_STOP();

        } else if ((HF16 == ATAN_TEST_CTRL.inpPrec) && (SP32 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_chf_sp_asm((cfixed16_t *)ATAN_INP_BUFF, ATAN_OUT_BUFF, count);
            CLOCK_STOP();

        } else if ((SP32 == ATAN_TEST_CTRL.inpPrec) && (HF16 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_csp_hf_asm(ATAN_INP_BUFF, (fixed16_t *)ATAN_OUT_BUFF, count);
            CLOCK_STOP();

        } else if ((SP32 == ATAN_TEST_CTRL.inpPrec) && (SP32 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_csp_sp_asm(ATAN_INP_BUFF, ATAN_OUT_BUFF, count);
            CLOCK_STOP();
        } else if ((HP16 == ATAN_TEST_CTRL.inpPrec) && (HP16 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_chp_hp_asm((cfloat16_t *)ATAN_INP_BUFF, (float16_t *)ATAN_OUT_BUFF, count);
            CLOCK_STOP();
        } else if ((HP16 == ATAN_TEST_CTRL.inpPrec) && (SP32 == ATAN_TEST_CTRL.outPrec)) {
            CLOCK_START();
            atan2_x64_chp_sp_asm((cfloat16_t *)ATAN_INP_BUFF, ATAN_OUT_BUFF, count);
            CLOCK_STOP();
        } else {
            CLOCK_START();
            atan2_x64_csp_hp_asm(ATAN_INP_BUFF, (float16_t *)ATAN_OUT_BUFF, count);
            CLOCK_STOP();
        }

        pipe_flush();

        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
