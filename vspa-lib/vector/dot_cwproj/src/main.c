// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          Dot product library tester source file.
//! @author         NXP Semiconductors.
// =============================================================================

#include <vspa/intrinsics.h>

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>
#include <time.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "vector.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
#define DOT_PROD_TEST_ALLOC_CIRC 0
#define DOT_PROD_TEST_ALLOC_LINE 1

struct DOT_PROD_TEST_CTRL_T {
    uint32_t inputLen;  // Input length (samples)
    uint32_t allocType; // Allocation type (0 for circular, 1 for linear)
} DOT_PROD_TEST_CTRL;

/* Maximum input length of one linear buffer */
#define DOT_PROD_TEST_MAX_INP_LEN 128

/* Misalignment (samples) of the 1st input buffer inside the circular buffer */
#define DOT_PROD_TEST_INP_CIRC_MISALIGN 13

/* Offset (samples) of the 2nd input buffer relative to 2nd input buffer inside the circular buffer */
#define DOT_PROD_TEST_INP_CIRC_OFF DOT_PROD_TEST_MAX_INP_LEN

/* Maximum input length of the circular buffer */
#define DOT_PROD_TEST_INP_CIRC_LEN (DOT_PROD_TEST_MAX_INP_LEN * 2)

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
static cfixed16_t DOT_PROD_TEST_INP1_LINE_BUFF[DOT_PROD_TEST_MAX_INP_LEN] _VSPA_VECTOR_ALIGN;
static cfixed16_t DOT_PROD_TEST_INP2_LINE_BUFF[DOT_PROD_TEST_MAX_INP_LEN] _VSPA_VECTOR_ALIGN;

static cfixed16_t DOT_PROD_TEST_INP_CIRC_BUFF[DOT_PROD_TEST_INP_CIRC_LEN] _VSPA_VECTOR_ALIGN;
static vspa_complex_float32 dot_prod;

// ----------------------------------------------------------------------------
//! @brief          Dot product main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t inp_len, inp_alloc, idx, num_lines;
    cfixed16_t *inp1_p;
    cfixed16_t *inp2_p;

    /* Init clock */
    CLOCK_INIT();

    while (1) {
        /* Testcase parameters */
        inp_len = DOT_PROD_TEST_CTRL.inputLen;
        inp_alloc = DOT_PROD_TEST_CTRL.allocType;

        /* Number of input lines */
        num_lines = inp_len / (_VSPA_AU_COUNT * 4 / sizeof(inp1_p[0]));

        /* Clear input circular buffer */
        mem_set(DOT_PROD_TEST_INP_CIRC_BUFF, 0xFFFF, sizeof(DOT_PROD_TEST_INP_CIRC_BUFF));

        /* Clear output dot product */
        dot_prod.imag = 0;
        dot_prod.real = 0;

        /* Produce dot product input circular buffer with misalignment (e.g. by the Decimator) */
        if (DOT_PROD_TEST_ALLOC_CIRC == inp_alloc) {
            for (idx = 0; idx < inp_len; idx++) {
                DOT_PROD_TEST_INP_CIRC_BUFF[(idx + DOT_PROD_TEST_INP_CIRC_MISALIGN) % DOT_PROD_TEST_INP_CIRC_LEN] =
                    DOT_PROD_TEST_INP1_LINE_BUFF[idx];
                DOT_PROD_TEST_INP_CIRC_BUFF[(idx + DOT_PROD_TEST_INP_CIRC_MISALIGN + DOT_PROD_TEST_INP_CIRC_OFF) %
                                            DOT_PROD_TEST_INP_CIRC_LEN] = DOT_PROD_TEST_INP2_LINE_BUFF[idx];
            }

            inp1_p = &DOT_PROD_TEST_INP_CIRC_BUFF[(DOT_PROD_TEST_INP_CIRC_MISALIGN) % DOT_PROD_TEST_INP_CIRC_LEN];
            inp2_p = &DOT_PROD_TEST_INP_CIRC_BUFF[(DOT_PROD_TEST_INP_CIRC_MISALIGN + DOT_PROD_TEST_INP_CIRC_OFF) %
                                                  DOT_PROD_TEST_INP_CIRC_LEN];
        } else {
            inp1_p = DOT_PROD_TEST_INP1_LINE_BUFF;
            inp2_p = DOT_PROD_TEST_INP2_LINE_BUFF;
        }

        /* -------------------- Dot product -------------------- */
        if (DOT_PROD_TEST_ALLOC_CIRC == inp_alloc) {
            CLOCK_START();
            dot_prod_circ_x32chf_csp_asm(inp1_p, inp2_p, &dot_prod, &DOT_PROD_TEST_INP_CIRC_BUFF[0],
                                         sizeof(DOT_PROD_TEST_INP_CIRC_BUFF), num_lines);
            CLOCK_STOP();
        } else {
            CLOCK_START();
            dot_prod_line_x32chf_csp_asm(inp1_p, inp2_p, &dot_prod, num_lines);
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
