// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "ditfft.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
static unsigned int input_buffer[4096 + 32] _VSPA_VECTOR_ALIGN;
static unsigned int output_buffer[4096] _VSPA_VECTOR_ALIGN;
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

    N = config_buffer[0];
    inv = config_buffer[1];
    fft_prec_type = config_buffer[2];
    offset = config_buffer[3];

    host_reset();

    if (N == 128) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIT128_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT128_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            break;

        case 1:
            if (inv)
                ifftDIT128_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT128_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            break;
        }
    } else if (N == 512) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIT512_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT512_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            break;

        case 1:
            if (inv)
                ifftDIT512_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT512_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            break;

        case 2:
            if (inv)
                ifftDIT512_sflsfl((vspa_complex_float32 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            else
                fftDIT512_sflsfl((vspa_complex_float32 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            break;
        }
    } else if (N == 1024) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIT1024_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT1024_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            break;

        case 1:
            if (inv)
                ifftDIT1024_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT1024_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            break;
        }
    } else if (N == 2048) {
        switch (fft_prec_type) {
        case 0:
            if (inv)
                ifftDIT2048_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT2048_hfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            break;

        case 1:
            if (inv)
                ifftDIT2048_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_fixed16 *)output_buffer);
            else
                fftDIT2048_sfl((vspa_complex_float16 *)(input_buffer + offset), (vspa_complex_float32 *)output_buffer);
            break;
        }
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
