// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          Frequency domain correction library tester source file.
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

#include "freq_domain_corr.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
struct FREQ_DOMAIN_CORR_TEST_CTRL_T {
    uint32_t num_sbc;     // Number of subcarriers per stream
    uint32_t num_streams; // NUmber of streams
    int32_t phase_ramp;   // Phase ramp
    int32_t phase_init;   // Initial phase
} FREQ_DOMAIN_CORR_TEST_CTRL;

//#define TEST_MAX_NUM_LINES 32
#define TEST_MAX_NUM_LINES 16
//#define TEST_MAX_NUM_NSS    8
#define TEST_MAX_NUM_NSS 4

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
void mem_copy(void *src_ptr, void *dst_ptr, size_t size) __attribute__((optimize("O0"))) {
    uint32_t idx;
    for (idx = 0; idx < size; idx++) {
        *((uint16_t *)dst_ptr)++ = *((uint16_t *)src_ptr)++;
    }
}

void mem_set(void *ptr, uint16_t value, size_t num) __attribute__((optimize("O0"))) {
    uint32_t idx;
    for (idx = 0; idx < num; idx++) {
        *((uint16_t *)ptr)++ = value;
    }
}

/* Function to set random state for VRA, SX, V, etc...*/
void vspa_set() {
    /* Fill S0, S1, S2 with 1's and V with 2's*/
    __set_Smode(S0real1, S1real1, S2real1);
    __set_prec(single, single, single, single, half_fixed);
    __rd_S0();
    __rd_S1();
    __rd_S2();
    __rmad();
    __nop();
    __nop();
    __nop();
    __nop();

    /* Fill all VRA with 0x7FFF */
    __set_VRAptr_rV(_VR0);
    __wr(straight);
    __set_VRAptr_rV(_VR1);
    __wr(straight);
    __set_VRAptr_rV(_VR2);
    __wr(straight);
    __set_VRAptr_rV(_VR3);
    __wr(straight);
    __set_VRAptr_rV(_VR4);
    __wr(straight);
    __set_VRAptr_rV(_VR5);
    __wr(straight);
    __set_VRAptr_rV(_VR6);
    __wr(straight);
    __set_VRAptr_rV(_VR7);
    __wr(straight);
}

/* Flush pipeline */
void pipe_flush() __attribute__((optimize("O0"))) {
    __asm("fnop;");
    __asm("fnop;");
    __asm("fnop;");
}

// ----------------------------------------------------------------------------
//! @brief  Pilot tracking input/output buffers.
// ----------------------------------------------------------------------------
static cfloat16_t
    FREQ_DOMAIN_CORR_INP_OUT[FREQ_DOMAIN_CORR_NUM_SBC_PER_LINE * TEST_MAX_NUM_LINES * TEST_MAX_NUM_NSS] _VSPA_VECTOR_ALIGN;
static cfloat16_t FREQ_DOMAIN_CORR_SCRATCH[FREQ_DOMAIN_CORR_NUM_SBC_PER_LINE * TEST_MAX_NUM_LINES] __align_vec
    __attribute__((section(".ibss")));
static cfloat32_t FREQ_DOMAIN_CORR_GAIN_CPX;

// ----------------------------------------------------------------------------
//! @brief          Main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t num_sbc, num_lines, num_streams;
    int32_t phase_ramp, phase_init;

    /* Init clock */
    CLOCK_INIT();

    while (1) {
        /* Testcase parameters */
        num_sbc = FREQ_DOMAIN_CORR_TEST_CTRL.num_sbc;
        num_streams = FREQ_DOMAIN_CORR_TEST_CTRL.num_streams;
        phase_ramp = FREQ_DOMAIN_CORR_TEST_CTRL.phase_ramp;
        phase_init = FREQ_DOMAIN_CORR_TEST_CTRL.phase_init;

        num_lines = num_sbc / FREQ_DOMAIN_CORR_NUM_SBC_PER_LINE;

        /* Clear output buffers to avoid pollution between test cases */
        // mem_set(PILOT_TRACKING_TEST_FREQ_OFF_EST_F, 0xFFFF, sizeof(PILOT_TRACKING_TEST_FREQ_OFF_EST_F));
        // mem_set(PILOT_TRACKING_TEST_GAIN_CPX,       0xFFFF, sizeof(PILOT_TRACKING_TEST_GAIN_CPX));

        /* Function to pollute VRA, SX, V, etc...*/
        vspa_set();

        /* Call frequency domain correction */
        switch (num_sbc) {
        case 64:
            CLOCK_START();
            freq_domain_corr_64sbc(FREQ_DOMAIN_CORR_INP_OUT, &FREQ_DOMAIN_CORR_GAIN_CPX, FREQ_DOMAIN_CORR_SCRATCH, phase_ramp,
                                   phase_init, num_streams);
            CLOCK_STOP();
            break;

        case 128:
            CLOCK_START();
            freq_domain_corr_128sbc(FREQ_DOMAIN_CORR_INP_OUT, &FREQ_DOMAIN_CORR_GAIN_CPX, FREQ_DOMAIN_CORR_SCRATCH, phase_ramp,
                                    phase_init, num_streams);
            CLOCK_STOP();
            break;

        case 256:
            CLOCK_START();
            freq_domain_corr_256sbc(FREQ_DOMAIN_CORR_INP_OUT, &FREQ_DOMAIN_CORR_GAIN_CPX, FREQ_DOMAIN_CORR_SCRATCH, phase_ramp,
                                    phase_init, num_streams);
            CLOCK_STOP();
            break;

        case 512:
            CLOCK_START();
            freq_domain_corr_512sbc(FREQ_DOMAIN_CORR_INP_OUT, &FREQ_DOMAIN_CORR_GAIN_CPX, FREQ_DOMAIN_CORR_SCRATCH, phase_ramp,
                                    phase_init, num_streams);
            CLOCK_STOP();
            break;

        case 1024:
            CLOCK_START();
            freq_domain_corr_1024sbc(FREQ_DOMAIN_CORR_INP_OUT, &FREQ_DOMAIN_CORR_GAIN_CPX, FREQ_DOMAIN_CORR_SCRATCH, phase_ramp,
                                     phase_init, num_streams);
            CLOCK_STOP();
            break;

        default:
            __swbreak();
        }

        pipe_flush();

        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
