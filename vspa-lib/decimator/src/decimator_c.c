// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           decimator_c.c
//! @brief          FIR decimation C source file
//! @author         NXP Semiconductors.
//! @ingroup        GROUP_DECIM
//!
//! The decimator.c implements the decimator kernels in C code with intrinsics.
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

extern float32_t DECIM_FLT_BUFF[DECIM_MAX_FLT_LEN] _VSPA_VECTOR_ALIGN;

extern cfixed16_t DECIM_4X_SCRATCH_MEM[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE * DECIM_FACT_2X] _VSPA_VECTOR_ALIGN;
extern cfixed16_t DECIM_8X_SCRATCH_MEM[DECIM_MAX_OUT_LINES * DECIM_SAMP_PER_LINE * DECIM_FACT_4X] _VSPA_VECTOR_ALIGN;

// ---------------------------------------------------------------------------
// TODO: Circular buffer works for "O0" but not "O3" !!!!
// ---------------------------------------------------------------------------
void decimator_2x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *in_circ_p, size_t in_circ_size, uint32_t num_out_lines) {
    uint32_t idx0, idx1;

    __set_creg(255, 0);

    /* Initialize VRA pointers */
    __clr_VRA();
    __set_VRAptr_rS0(4 * 64);
    __set_VRAincr_rS0(4);
    __set_VRAincr_rV(32);
    __set_VRAptr_rSt(6);

    /* Set input pointer as circular buffer */
    inp_p = __modulo_ptr_add(inp_p, -(DECIM_FLT_LEN - 1), in_circ_p, in_circ_size / 2);

    /* Initialize prec & mode */
    __set_prec(single, half_fixed, half_fixed, single, half_fixed);
    __set_Smode(S0i1r1i1r1, S1i2i1r2r1, S2zeros);

    /* Load filter coefficients */
    __ld_vec_asm(DECIM_FLT_BUFF);
    __ld_Rx(normal, 4);

    for (idx1 = 0; idx1 < num_out_lines; idx1++) {
#pragma loop_count(2, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 1);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 3);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(out_p);
        out_p += _VSPA_AU_COUNT * 2;
    }
}

// ---------------------------------------------------------------------------
void decimator_4x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *in_circ_p, DECIM_4X_PERSIST_MEM_T *persist_p,
                    size_t in_circ_size, uint32_t num_out_lines) {
    uint32_t idx0, idx1;
    cfixed16_t *scratch_l_p;  // scratch load pointer
    cfixed16_t *scratch_s_p;  // scratch store pointer
    cfixed16_t *persist_ls_p; // persist load/store pointer

    __set_creg(255, 0);

    /* Initialize VRA pointers */
    __clr_VRA();
    __set_VRAptr_rS0(4 * 64);
    __set_VRAincr_rS0(4);
    __set_VRAincr_rV(32);
    __set_VRAptr_rSt(6);

    /* Initialize pointers */
    scratch_l_p = DECIM_4X_SCRATCH_MEM;
    scratch_s_p = DECIM_4X_SCRATCH_MEM;

    scratch_l_p += 32 - (DECIM_FLT_LEN - 1);
    persist_ls_p = ((cfixed16_t *)persist_p) + 32 - (DECIM_FLT_LEN - 1);

    /* Set input pointer as circular buffer */
    inp_p = __modulo_ptr_add(inp_p, -(DECIM_FLT_LEN - 1), in_circ_p, in_circ_size / 2);

    /* Initialize prec & mode */
    __set_prec(single, half_fixed, half_fixed, single, half_fixed);
    __set_Smode(S0i1r1i1r1, S1i2i1r2r1, S2zeros);

    /* Load filter coefficients */
    __ld_vec_asm(DECIM_FLT_BUFF);
    __ld_Rx(normal, 4);

    /* ------------------------- 1st 2x Decimator ------------------------- */
    for (idx1 = 0; idx1 < 2 * num_out_lines; idx1++) {
#pragma loop_count(4, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 1);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 3);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(scratch_s_p);
        scratch_s_p += _VSPA_AU_COUNT * 2;
    }

    /* ------------------------- 2nd 2x Decimator ------------------------- */
    /* One iteration outside of loop */

    __set_VRAptr_rV(6 * 64);

    /* Process first input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(0 * 64);

    __ld_vec_asm(persist_ls_p);
    __ld_Rx(h2l, 0);
    __ld_vec_asm(scratch_l_p);
    __ld_Rx(l2h_h2l, 0);
    scratch_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch_l_p);
    __ld_Rx(l2h, 1);
    scratch_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R0R1r4);
    __rd_S0();
    __rd_S1();
    __rd_S2();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Process second input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(2 * 64);

    __ld_vec_asm(scratch_l_p);
    __ld_Rx(h2l, 2);
    scratch_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch_l_p);
    __ld_Rx(l2h_h2l, 2);
    scratch_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch_l_p);
    __ld_Rx(l2h, 3);
    scratch_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R2R3r4);
    __rd_S0();
    __rd_S1();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Store to DMEM */
    __st_vec_asm(out_p);
    out_p += _VSPA_AU_COUNT * 2;

    for (idx1 = 0; idx1 < num_out_lines - 1; idx1++) {
#pragma loop_count(1, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(scratch_l_p);
        __ld_Rx(h2l, 0);
        scratch_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch_l_p);
        __ld_Rx(l2h_h2l, 0);
        scratch_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch_l_p);
        __ld_Rx(l2h, 1);
        scratch_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(scratch_l_p);
        __ld_Rx(h2l, 2);
        scratch_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch_l_p);
        __ld_Rx(l2h_h2l, 2);
        scratch_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch_l_p);
        __ld_Rx(l2h, 3);
        scratch_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(out_p);
        out_p += _VSPA_AU_COUNT * 2;
    }

    /* Store persistent for next kernel call */
    scratch_s_p -= _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch_s_p);
    __ld_Rx(normal, 0);
    __set_VRAptr_rSt(0);
    __st_vec_asm(persist_ls_p);
}

// ---------------------------------------------------------------------------
void decimator_8x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *in_circ_p, DECIM_8X_PERSIST_MEM_T *persist_p,
                    size_t in_circ_size, uint32_t num_out_lines) {
    uint32_t idx0, idx1;
    cfixed16_t *scratch1_l_p; // scratch1 load pointer
    cfixed16_t *scratch1_s_p; // scratch1 store pointer
    cfixed16_t *scratch2_l_p; // scratch2 load pointer
    cfixed16_t *scratch2_s_p; // scratch2 store pointer
    cfixed16_t *persist_ls_p; // persist load/store pointer

    __set_creg(255, 0);

    /* Initialize VRA pointers */
    __clr_VRA();
    __set_VRAptr_rS0(4 * 64);
    __set_VRAincr_rS0(4);
    __set_VRAincr_rV(32);
    __set_VRAptr_rSt(6);

    /* Initialize pointers */
    scratch1_l_p = DECIM_8X_SCRATCH_MEM;
    scratch1_s_p = DECIM_8X_SCRATCH_MEM;

    scratch2_l_p = DECIM_8X_SCRATCH_MEM;
    scratch2_s_p = DECIM_8X_SCRATCH_MEM;

    scratch1_l_p += 32 - (DECIM_FLT_LEN - 1);
    scratch2_l_p += 32 - (DECIM_FLT_LEN - 1);

    persist_ls_p = ((cfixed16_t *)persist_p) + 32 - (DECIM_FLT_LEN - 1);

    /* Set input pointer as circular buffer */
    inp_p = __modulo_ptr_add(inp_p, -(DECIM_FLT_LEN - 1), in_circ_p, in_circ_size / 2);

    /* Initialize prec & mode */
    __set_prec(single, half_fixed, half_fixed, single, half_fixed);
    __set_Smode(S0i1r1i1r1, S1i2i1r2r1, S2zeros);

    /* Load filter coefficients */
    __ld_vec_asm(DECIM_FLT_BUFF);
    __ld_Rx(normal, 4);

    /* ------------------------- 1st 2x Decimator ------------------------- */
    for (idx1 = 0; idx1 < 4 * num_out_lines; idx1++) {
#pragma loop_count(8, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 0);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 1);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(inp_p);
        __ld_Rx(h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h_h2l, 2);
        inp_p = __modulo_ptr_add(inp_p, +_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);
        __ld_vec_asm(inp_p);
        __ld_Rx(l2h, 3);
        inp_p = __modulo_ptr_add(inp_p, -_VSPA_AU_COUNT * 2, in_circ_p, in_circ_size / 2);

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(scratch1_s_p);
        scratch1_s_p += _VSPA_AU_COUNT * 2;
    }

    /* ------------------------- 2nd 2x Decimator ------------------------- */
    /* One iteration outside of loop */

    __set_VRAptr_rV(6 * 64);

    /* Process first input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(0 * 64);

    __ld_vec_asm(persist_ls_p);
    __ld_Rx(h2l, 0);
    persist_ls_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch1_l_p);
    __ld_Rx(l2h_h2l, 0);
    scratch1_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch1_l_p);
    __ld_Rx(l2h, 1);
    scratch1_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R0R1r4);
    __rd_S0();
    __rd_S1();
    __rd_S2();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Process second input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(2 * 64);

    __ld_vec_asm(scratch1_l_p);
    __ld_Rx(h2l, 2);
    scratch1_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch1_l_p);
    __ld_Rx(l2h_h2l, 2);
    scratch1_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch1_l_p);
    __ld_Rx(l2h, 3);
    scratch1_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R2R3r4);
    __rd_S0();
    __rd_S1();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Store to DMEM */
    __st_vec_asm(scratch2_s_p);
    scratch2_s_p += _VSPA_AU_COUNT * 2;

    for (idx1 = 0; idx1 < 2 * num_out_lines - 1; idx1++) {
#pragma loop_count(3, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(h2l, 0);
        scratch1_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(l2h_h2l, 0);
        scratch1_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(l2h, 1);
        scratch1_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(h2l, 2);
        scratch1_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(l2h_h2l, 2);
        scratch1_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch1_l_p);
        __ld_Rx(l2h, 3);
        scratch1_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(scratch2_s_p);
        scratch2_s_p += _VSPA_AU_COUNT * 2;
    }

    /* ------------------------- 3rd 2x Decimator ------------------------- */
    /* One iteration outside of loop */

    __set_VRAptr_rV(6 * 64);

    /* Process first input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(0 * 64);

    __ld_vec_asm(persist_ls_p);
    __ld_Rx(h2l, 0);
    persist_ls_p -= _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch2_l_p);
    __ld_Rx(l2h_h2l, 0);
    scratch2_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch2_l_p);
    __ld_Rx(l2h, 1);
    scratch2_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R0R1r4);
    __rd_S0();
    __rd_S1();
    __rd_S2();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Process second input line */
    __set_VRAptr_rS0(4 * 64);
    __set_VRAptr_rS1(2 * 64);

    __ld_vec_asm(scratch2_l_p);
    __ld_Rx(h2l, 2);
    scratch2_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch2_l_p);
    __ld_Rx(l2h_h2l, 2);
    scratch2_l_p += _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch2_l_p);
    __ld_Rx(l2h, 3);
    scratch2_l_p -= _VSPA_AU_COUNT * 2;

    __set_rot(R2R3r4);
    __rd_S0();
    __rd_S1();
    __cmad();
    __ror();

    for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
        __rd_S0();
        __rd_S1();
        __cmac();
        __ror();
    }

    __wr(hlinecplx);

    /* Store to DMEM */
    __st_vec_asm(out_p);
    out_p += _VSPA_AU_COUNT * 2;

    for (idx1 = 0; idx1 < num_out_lines - 1; idx1++) {
#pragma loop_count(1, 0xFFFF)

        __set_VRAptr_rV(6 * 64);

        /* Process first input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(0 * 64);

        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(h2l, 0);
        scratch2_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(l2h_h2l, 0);
        scratch2_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(l2h, 1);
        scratch2_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R0R1r4);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Process second input line */
        __set_VRAptr_rS0(4 * 64);
        __set_VRAptr_rS1(2 * 64);

        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(h2l, 2);
        scratch2_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(l2h_h2l, 2);
        scratch2_l_p += _VSPA_AU_COUNT * 2;
        __ld_vec_asm(scratch2_l_p);
        __ld_Rx(l2h, 3);
        scratch2_l_p -= _VSPA_AU_COUNT * 2;

        __set_rot(R2R3r4);
        __rd_S0();
        __rd_S1();
        __cmad();
        __ror();

        for (idx0 = 0; idx0 < DECIM_FLT_LEN / 2 - 1; idx0++) {
#pragma loop_count(7, 15)
            __rd_S0();
            __rd_S1();
            __cmac();
            __ror();
        }

        __wr(hlinecplx);

        /* Store to DMEM */
        __st_vec_asm(out_p);
        out_p += _VSPA_AU_COUNT * 2;
    }

    /* Store persistent for next kernel call */
    scratch1_s_p -= _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch1_s_p);
    __ld_Rx(normal, 0);
    __set_VRAptr_rSt(0);
    __st_vec_asm(persist_ls_p);
    persist_ls_p += _VSPA_AU_COUNT * 2;

    scratch2_s_p -= _VSPA_AU_COUNT * 2;
    __ld_vec_asm(scratch2_s_p);
    __ld_Rx(normal, 2);
    __set_VRAptr_rSt(2);
    __st_vec_asm(persist_ls_p);
}
