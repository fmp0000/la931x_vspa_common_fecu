// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          LOG library tester source file.
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

#include "log.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
struct LOG_TEST_CTRL_T {
    uint32_t inputLen;  // Input length (samples)
    LOG_FACT_T logFact; // Logarithm factor
} LOG_TEST_CTRL;

#define LOG_TEST_MAX_LEN 64

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
static float32_t LOG_INP_BUFF[LOG_TEST_MAX_LEN];
static float32_t LOG_OUT_BUFF[LOG_TEST_MAX_LEN];

// ----------------------------------------------------------------------------
//! @brief          LOG main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t idx;

    /* Init clock */
    CLOCK_INIT();

    while (1) {
        /* Clear output buffer */
        mem_set(LOG_OUT_BUFF, 0xFFFF, sizeof(LOG_OUT_BUFF));

        for (idx = 0; idx < LOG_TEST_CTRL.inputLen; idx++) {
            // Read input
            float32_t inp = LOG_INP_BUFF[idx];
            LOG_FACT_T log_fact = LOG_TEST_CTRL.logFact;

            // Compute log
            CLOCK_START();
            float32_t out = log_asm(inp, log_fact);
            CLOCK_STOP();

            // Write output
            LOG_OUT_BUFF[idx] = out;
        }

        pipe_flush();

        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
