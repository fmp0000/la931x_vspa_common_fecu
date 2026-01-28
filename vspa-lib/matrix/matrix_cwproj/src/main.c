// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           harness.c
//! @brief          Matrix library tester source file.
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

#include "matrix.h"

// ----------------------------------------------------------------------------
//! @brief  Tester related variables and definitions.
// ----------------------------------------------------------------------------
#define HALF_FIXED 0
#define HALF_FLOAT 1
#define SINGLE_PRECISION 2
#define DOUBLE_PRECISION 3

struct MATRIX_TEST_CTRL_T {
    uint32_t vecPrec;
    uint32_t matPrec;
    uint32_t outPrec;
    uint32_t dim1;
    uint32_t dim2;
    uint32_t dim3;
    uint32_t matInterp;
} MATRIX_TEST_CTRL;

#define MATRIX_TEST_VEC_DIM1_MAX 64
#define MATRIX_TEST_MAT_DIM1_MAX 64
#define MATRIX_TEST_DIM2_MAX 4
#define MATRIX_TEST_DIM3_MAX 8
//#define MATRIX_TEST_VEC_DIM1_MAX   256
//#define MATRIX_TEST_MAT_DIM1_MAX   64
//#define MATRIX_TEST_DIM2_MAX        8
//#define MATRIX_TEST_DIM3_MAX        8
/* Define this macro for testing the wrapper function or undefine it for individual kernel testing */
#define TEST_WRAPPER

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
//! @brief  Matrix multiplication input/output buffers.
// ----------------------------------------------------------------------------
cfloat16_t MATRIX_MULT_INP_VEC[MATRIX_TEST_VEC_DIM1_MAX * MATRIX_TEST_DIM2_MAX] _VSPA_VECTOR_ALIGN;
cfloat32_t MATRIX_MULT_INP_MAT[MATRIX_TEST_MAT_DIM1_MAX * MATRIX_TEST_DIM3_MAX * MATRIX_TEST_DIM2_MAX] __align_vec
    __attribute__((section(".ibss")));
cfloat16_t MATRIX_MULT_OUT_VEC[MATRIX_TEST_VEC_DIM1_MAX * MATRIX_TEST_DIM3_MAX] _VSPA_VECTOR_ALIGN;

// ----------------------------------------------------------------------------
//! @brief          Matrix main tester function.
//! @return         This function does not return.
// ----------------------------------------------------------------------------
void main(void) //__attribute__(( optimize( "O0" )))
{
    uint32_t vec_prec, mat_prec, out_prec, dim1, dim2, dim3, mat_interp;

    /* Init clock */
    CLOCK_INIT();

    while (1) {
        /* Testcase parameters */
        vec_prec = MATRIX_TEST_CTRL.vecPrec;
        mat_prec = MATRIX_TEST_CTRL.matPrec;
        out_prec = MATRIX_TEST_CTRL.outPrec;
        dim1 = MATRIX_TEST_CTRL.dim1;
        dim2 = MATRIX_TEST_CTRL.dim2;
        dim3 = MATRIX_TEST_CTRL.dim3;
        mat_interp = MATRIX_TEST_CTRL.matInterp;

        /* Clear output buffers to avoid pollution between test cases */
        mem_set(MATRIX_MULT_OUT_VEC, 0xFFFF, sizeof(MATRIX_MULT_OUT_VEC));

        /* Function to pollute VRA, SX, V, etc...*/
        vspa_set();

#ifdef TEST_WRAPPER
        /* --------------------------- WRAPPER TESTING -----------------------------------*/
        MAT_BMULT_RETURN_T error;

        if (mat_interp == 1) {
            /* ------------------------ MATRIX INTERPOLATION 1 -------------------------- */
            if ((HALF_FIXED == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                CLOCK_START();
                error = mat_bmult((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                  (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim2, dim3);
                CLOCK_STOP();
                if (error)
                    __swbreak();

            } else if ((HALF_FLOAT == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                CLOCK_START();
                error = mat_bmult((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                  (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim2, dim3);
                CLOCK_STOP();
                if (error)
                    __swbreak();

            } else {
                // Precision combination not supported
                __swbreak();
            }
        } else if (mat_interp == 4) {
            /* ------------------------ MATRIX INTERPOLATION 4 -------------------------- */
            if ((HALF_FIXED == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                CLOCK_START();
                error = mat_bmult_i4((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                     (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim2, dim3);
                CLOCK_STOP();
                if (error)
                    __swbreak();

            } else if ((HALF_FLOAT == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                CLOCK_START();
                error = mat_bmult_i4((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                     (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim2, dim3);
                CLOCK_STOP();
                if (error)
                    __swbreak();

            } else {
                // Precision combination not supported
                __swbreak();
            }

        } else {
            // Matrix interpolation order not supported
            __swbreak();
        }

#else
        /* ---------------------- INDIVIDUAL KERNEL TESTING ------------------------------*/
        if (mat_interp == 1) {
            /* ------------------------ MATRIX INTERPOLATION 1 -------------------------- */
            if ((HALF_FIXED == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                if (dim2 == 1) {
                    CLOCK_START();
                    mat_bmult_d1x1xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                      (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else if (dim2 == 2) {
                    CLOCK_START();
                    mat_bmult_d1x2xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                      (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else {
                    CLOCK_START();
                    mat_bmult_64xd2xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                       (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim2, dim3);
                    CLOCK_STOP();
                }

            } else if ((HALF_FLOAT == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {

                if (dim2 == 1) {
                    CLOCK_START();
                    mat_bmult_d1x1xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                      (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else if (dim2 == 2) {
                    CLOCK_START();
                    mat_bmult_d1x2xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                      (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else {
                    CLOCK_START();
                    mat_bmult_64xd2xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                       (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim2, dim3);
                    CLOCK_STOP();
                }

            } else {
                // Precision combination not supported
                __swbreak();
            }

        } else if (mat_interp == 4) {
            /* ------------------------ MATRIX INTERPOLATION 4 -------------------------- */
            if ((HALF_FIXED == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {
                if (dim2 == 1) {
                    CLOCK_START();
                    mat_bmult_i4_d1x1xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                         (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else if (dim2 == 2) {
                    CLOCK_START();
                    mat_bmult_i4_d1x2xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                         (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else {
                    CLOCK_START();
                    mat_bmult_i4_256xd2xd3((cfixed16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                           (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim2, dim3);
                    CLOCK_STOP();
                }

            } else if ((HALF_FLOAT == vec_prec) && (SINGLE_PRECISION == mat_prec) && (HALF_FLOAT == out_prec)) {

                if (dim2 == 1) {
                    CLOCK_START();
                    mat_bmult_i4_d1x1xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                         (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else if (dim2 == 2) {
                    CLOCK_START();
                    mat_bmult_i4_d1x2xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                         (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim1, dim3);
                    CLOCK_STOP();

                } else {
                    CLOCK_START();
                    mat_bmult_i4_256xd2xd3((cfloat16_t *)MATRIX_MULT_INP_VEC, (cfloat32_t *)MATRIX_MULT_INP_MAT,
                                           (cfloat16_t *)MATRIX_MULT_OUT_VEC, dim2, dim3);
                    CLOCK_STOP();
                }

            } else {
                // Precision combination not supported
                __swbreak();
            }

        } else {
            // Matrix interpolation order not supported
            __swbreak();
        }

#endif

        pipe_flush();

        TCL_SYNC();
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
