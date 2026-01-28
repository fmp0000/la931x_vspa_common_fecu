// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          DECIMATOR library tester source file.
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

#include "decimator.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
#define DECIM_TEST_ASM 0
#define DECIM_TEST_C 1

struct DECIM_TEST_T {
    uint32_t decimFact; // Decimation factor (2,4,8)
    uint32_t numBlocks; // Number of blocks (block-wise processing)
    uint32_t outputLen; // Output length (in samples) for one input block
} DECIM_TEST_CTRL;

/* Choose which type of kernels to test: ASM or C implementation */
#define DECIM_TEST_TYPE DECIM_TEST_ASM

/* Decimator maximum factor */
#define DECIM_TEST_MAX_FACT DECIM_FACT_8X

/* Decimator maximum number of blocks */
//#define DECIM_TEST_MAX_NUM_BLOCKS   9
#define DECIM_TEST_MAX_NUM_BLOCKS 4

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
void mem_copy(void *src_ptr, void *dst_ptr, size_t size) __attribute__((optimize("O0"))) {
    uint32_t idx;
    for (idx = 0; idx < size; idx++) {
        *((uint16_t *)dst_ptr)++ = *((uint16_t *)src_ptr)++;
    }
}

/* Flush pipeline */
void pipe_flush() __attribute__((optimize("O0"))) {
    __asm("fnop;");
    __asm("fnop;");
    __asm("fnop;");
}

// ----------------------------------------------------------------------------
//! @brief  Tester input/output buffer used to emulate producer of decimator
//!         input data and consumer of decimator output data.
//! FORINT  Ignore these buffers for integration.
// ----------------------------------------------------------------------------
cfixed16_t DECIM_TEST_INP_BUFF[DECIM_TEST_MAX_NUM_BLOCKS * DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE *
                               DECIM_TEST_MAX_FACT] _VSPA_VECTOR_ALIGN;
cfixed16_t DECIM_TEST_OUT_BUFF[DECIM_TEST_MAX_NUM_BLOCKS * DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE *
                               DECIM_TEST_MAX_FACT] __align_vec __attribute__((section(".ibss")));

// ----------------------------------------------------------------------------
//! @brief  Kernel input/output/persistent buffers.
//! FORINT  For integration use the actual value and not the maximum for the
//!         decimation factor. Also change the number of maximum output lines
//!         in the kernel API header file.
//! FORINT  Allocate only one persistent buffer for the used kernel.
// ----------------------------------------------------------------------------
cfixed16_t DECIM_INP_BUFF[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE * DECIM_NUM_INP_BUFFERS * DECIM_TEST_MAX_FACT] __align_vec
    __attribute__((section(".ibss")));
cfixed16_t DECIM_OUT_BUFF[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE] __align_vec __attribute__((section(".ibss")));

DECIM_4X_PERSIST_MEM_T DECIM_4X_PERSIST_MEM;
DECIM_8X_PERSIST_MEM_T DECIM_8X_PERSIST_MEM;

// ----------------------------------------------------------------------------
//! @brief          Decimator main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t test_num_blocks, out_len;
    uint32_t decim_fact, out_num_lines;
    uint32_t test_block_idx, inp_block_idx;
    size_t inp_circ_size;

    /* Init clock */
    CLOCK_INIT();

    /* Testcase parameters */
    test_num_blocks = DECIM_TEST_CTRL.numBlocks;
    out_len = DECIM_TEST_CTRL.outputLen;
    decim_fact = DECIM_TEST_CTRL.decimFact;

    /* Derived parameters - output DMEM lines per block */
    out_num_lines = out_len / DECIM_SAMP_PER_LINE;

    /* Input circular buffer size */
    inp_circ_size = out_num_lines * DECIM_SAMP_PER_LINE * DECIM_NUM_INP_BUFFERS * decim_fact * sizeof(DECIM_INP_BUFF[0]);

    for (test_block_idx = 0; test_block_idx < test_num_blocks; test_block_idx++) {
        /* Input block index */
        inp_block_idx = (test_block_idx % DECIM_NUM_INP_BUFFERS);

        /* Produce input data (e.g. DMA) of current input block */
        mem_copy(&DECIM_TEST_INP_BUFF[test_block_idx * out_len * decim_fact], &DECIM_INP_BUFF[inp_block_idx * out_len * decim_fact],
                 out_len * decim_fact * sizeof(DECIM_INP_BUFF[0]));

#if (DECIM_TEST_TYPE == DECIM_TEST_ASM)

        /* --------------------- DECIMATOR ASM implementation --------------------- */
        if (DECIM_FACT_2X == decim_fact) {
            /* -------------------- DECIMATOR 2x ASM ------------------------------ */
            if (out_num_lines == 1) {
                CLOCK_START();
                decimator_2x_32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_2X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                  inp_circ_size);
                CLOCK_STOP();

            } else {
                CLOCK_START();
                decimator_2x_x32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_2X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                   inp_circ_size, out_num_lines);
                CLOCK_STOP();
            }

        } else if (DECIM_FACT_4X == decim_fact) {
            /* -------------------- DECIMATOR 4x ASM ------------------------------ */
            if (out_num_lines == 1) {
                CLOCK_START();
                decimator_4x_32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_4X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                  &DECIM_4X_PERSIST_MEM, inp_circ_size);
                CLOCK_STOP();

            } else {
                CLOCK_START();
                decimator_4x_x32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_4X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                   &DECIM_4X_PERSIST_MEM, inp_circ_size, out_num_lines);
                CLOCK_STOP();
            }

        } else if (DECIM_FACT_8X == decim_fact) {

            /* -------------------- DECIMATOR 8x ASM ------------------------------ */
            if (out_num_lines == 1) {
                CLOCK_START();
                decimator_8x_32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_8X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                  &DECIM_8X_PERSIST_MEM, inp_circ_size);
                CLOCK_STOP();

            } else {
                CLOCK_START();
                decimator_8x_x32hf(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_8X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                                   &DECIM_8X_PERSIST_MEM, inp_circ_size, out_num_lines);
                CLOCK_STOP();
            }
        }

#else

        /* --------------------- DECIMATOR C implementation ----------------------- */
        if (DECIM_FACT_2X == decim_fact) {
            /* -------------------- DECIMATOR 2x C -------------------------------- */
            CLOCK_START();
            decimator_2x_c(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_2X], DECIM_OUT_BUFF, DECIM_INP_BUFF, inp_circ_size,
                           out_num_lines);
            CLOCK_STOP();

        } else if (DECIM_FACT_4X == decim_fact) {
            /* -------------------- DECIMATOR 4x C -------------------------------- */
            CLOCK_START();
            decimator_4x_c(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_4X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                           &DECIM_4X_PERSIST_MEM, inp_circ_size, out_num_lines);
            CLOCK_STOP();

        } else if (DECIM_FACT_8X == decim_fact) {

            /* -------------------- DECIMATOR 8x C -------------------------------- */
            CLOCK_START();
            decimator_8x_c(&DECIM_INP_BUFF[inp_block_idx * out_len * DECIM_FACT_8X], DECIM_OUT_BUFF, DECIM_INP_BUFF,
                           &DECIM_8X_PERSIST_MEM, inp_circ_size, out_num_lines);
            CLOCK_STOP();
        }

#endif

        /* Consume output data - single buffer output */
        mem_copy(DECIM_OUT_BUFF, &DECIM_TEST_OUT_BUFF[test_block_idx * out_len], out_len * sizeof(DECIM_OUT_BUFF[0]));
    }

    pipe_flush();

    TCL_SYNC();

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();

    __builtin_done();
}
