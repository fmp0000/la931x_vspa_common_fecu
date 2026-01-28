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

#define FFTSIZE 1024

#define INPUTBUFF_SIZE (FFTSIZE + 32)
#define OUTPUTBUFF_SIZE FFTSIZE

#if FFTSIZE == 1024
#define INPLACE
#define FFT_FUNC fftDIF1024_hfx_hfx
#define BITREV_FUNC bitRev1024sEbyE
#endif

#if FFTSIZE == 512
#define FFT_FUNC fftDIF512_hfx_hfx
#define BITREV_FUNC bitRev512
#endif

#if FFTSIZE == 128
#define FFT_FUNC fftDIF128_hfx_hfx
#define BITREV_FUNC bitRev128
#endif

#if FFTSIZE == 64
#define FFT_FUNC fftDIF64_hfx_hfx
#define BITREV_FUNC bitRev64
#endif

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
#ifndef INPLACE
__attribute__((aligned(64))) vspa_complex_fixed16 input_buffer[INPUTBUFF_SIZE] __attribute__((aligned(64)));
__attribute__((aligned(64))) vspa_complex_fixed16 output_buffer[OUTPUTBUFF_SIZE] __attribute__((aligned(64)));
__attribute__((aligned(64))) vspa_complex_fixed16 output_buffer2[OUTPUTBUFF_SIZE] __attribute__((aligned(64)));
__attribute__((aligned(64))) unsigned int config_buffer[4];
#else
__attribute__((aligned(64))) vspa_complex_fixed16 input_buffer[INPUTBUFF_SIZE] __attribute__((aligned(64)));
#define output_buffer input_buffer
__attribute__((aligned(64))) vspa_complex_fixed16 output_buffer2[OUTPUTBUFF_SIZE] __attribute__((aligned(64)));
__attribute__((aligned(64))) unsigned int config_buffer[4];
#endif
unsigned int inv, offset;

extern uint32_t volatile ippu_args[];
extern void bitRev512(void);
extern void bitRev128(void);
extern void bitRev64(void);
extern void bitRev1024sEbyE(void);

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------

#define NCO_TONE

#ifdef NCO_TONE
#pragma optimization_level 0
vspa_complex_float32 gain;
vspa_complex_float32 *pgain;
uint32_t tone_freq_DAC, tone_phase_DAC;
void gen_single_tone(uint32_t fft_bin, uint32_t fft_size, int16_t *buffer) __attribute__((aligned(64))) {
    uint32_t i;

    gain.real = 0.9;
    gain.imag = 0;
    __clr_VRA();
    __set_prec(single, single, single, single, half_fixed);
    __set_creg(255, 8);
    __set_Smode(S0word, S1nco, S2zeros);
    __set_VRAptr_rV(_VR2);
    __set_VRAptr_rSt(2);
    __set_VRAincr_rV(_VRH);
    __set_range1_rV(2 * _VR, 2 * _VR + _VRH);
    __set_nco(normal, 0x1, 0);
    pgain = &gain;
    __ld_Rx_mem_unaligned(0, pgain);
    tone_freq_DAC = (uint32_t)((uint64_t)0x100000000 * (fft_size / 2 - fft_bin) / fft_size);
    __set_nco_freq(tone_freq_DAC);
    for (i = 0; i < fft_size / NLANE32; i++) {
        tone_phase_DAC = i * 32;
        __set_nco_phase(tone_phase_DAC);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __wr(hlinecplx);
        tone_phase_DAC += 16;
        __set_nco_phase(tone_phase_DAC);
        __rd_S0();
        __rd_S1();
        __rd_S2();
        __cmad();
        __wr(hlinecplx);
        __st_vec((vspa_vector_pair_fixed16 *)buffer + i);
    }
    // generated data is 2's complement, force DMA to do conversions

    return;
}
#pragma optimization_level reset
#else
#include <stdint.h>
#include <math.h>
#include <stdio.h>
#define M_PI 3.1415926535897932384626433832795
void gen_single_tone(uint32_t fft_bin, uint32_t fft_size, int16_t *signal) {
    for (int32_t i = 0; i < fft_size; i++) {
        double phase = 2.0 * M_PI * i * (fft_bin - fft_size / 2) / fft_size;
        signal[2 * i] = (int16_t)(32767.0 * cos(phase));
        signal[2 * i + 1] = (int16_t)(32767.0 * sin(phase));
        if ((int16_t)signal[2 * i] < 0)
            signal[2 * i] = (uint16_t)signal[2 * i] ^ (uint16_t)0x7fff;
        if ((int16_t)signal[2 * i + 1] < 0)
            signal[2 * i + 1] = (uint16_t)signal[2 * i + 1] ^ (uint16_t)0x7fff;
    }
}
#endif

uint32_t fft_bin = 1;
__attribute__((noreturn)) void main(void) {
    host_clear();

    gen_single_tone(fft_bin, FFTSIZE, (int16_t *)input_buffer);

    FFT_FUNC(input_buffer, (vspa_complex_fixed16 *)output_buffer, input_buffer, INPUTBUFF_SIZE * 2);

    if (ippu_is_busy()) {
        __swbreak(); //!< TODO: error on IPPU already busy!
    }

    // Copy arguments to IPPU data memory:
    ippu_args[0] = (unsigned int)(&output_buffer2[0]); // memcpy_ippu writes to this location.
    ippu_args[1] = (unsigned int)(&output_buffer[0]);  // memcpy_ippu from this location.

    ippu_arg_base((uint32_t)ippu_args);
    ippu_enable(BITREV_FUNC, IPPU_PEND_NONE | IPPU_MODE_16BIT); // Start IPPU

    // Wait for IPPU procedure memcpy() to complete:
    do { /* wait */
    } while (!ippu_is_done());

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
