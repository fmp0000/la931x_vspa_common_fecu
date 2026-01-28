// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"
#include "diffft.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================
#define INPUTBUFF_SIZE (4096 + 32)
#define OUTPUTBUFF_SIZE 4096

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
static vspa_complex_fixed16 input_buffer[INPUTBUFF_SIZE] _VSPA_VECTOR_ALIGN;
static vspa_complex_float32 output_buffer[OUTPUTBUFF_SIZE] _VSPA_VECTOR_ALIGN;
static unsigned int config_buffer[4];

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int N, inv, fft_prec_type, offset;

    host_reset();

    N = config_buffer[0];
    inv = config_buffer[1];
    fft_prec_type = config_buffer[2];
    offset = config_buffer[3];

    if (N == 64) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF64_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF64_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF64_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF64_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF64_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF64_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    } else if (N == 128) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF128_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF128_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF128_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF128_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF128_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF128_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    } else if (N == 256) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF256_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF256_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF256_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF256_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF256_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF256_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    } else if (N == 512) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF512_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF512_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF512_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF512_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF512_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF512_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    } else if (N == 1024) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF1024_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF1024_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF1024_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF1024_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF1024_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF1024_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    } else if (N == 2048) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIF2048_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF2048_hfx_sfl(input_buffer + offset, output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 1:
            if (inv)
                ifftDIF2048_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF2048_hfx_hfx(input_buffer + offset, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;

        case 2:
            if (inv)
                ifftDIF2048_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            else
                fftDIF2048_hfx_hfl(input_buffer + offset, (vspa_complex_float16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);
            break;
        }
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
