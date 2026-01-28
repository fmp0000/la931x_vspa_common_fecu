// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "mixer_update.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================
vspa_complex_float32 output_buffer[512] _VSPA_VECTOR_ALIGN;
vspa_complex_float32 gain_buffer[1] _VSPA_VECTOR_ALIGN;
unsigned int config_buffer[4];
structSigCondParams mixerParams;

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================
// ---------------------------------------------------------------------------
//! @brief           NCO Sequence generator
//!
//! @param[in]       pGain  	Pointer to complex gain
//! @param[out]      pOut  		Base address of output buffer
//! @param[in]       freq  		Mixer frequency
//! @param[in]       phase  	Mixer starting phase frequency
//! @return          phase_out 	Mixer next phase
//! @cycle
//! @stack         	 0
//!
//! This function generates a complex exponential sequence in single precision with specified frequency and phase. It returns the
//! updated phase.
//!
//! @attention       Output buffers address must be DMEM line aligned
// ---------------------------------------------------------------------------
extern unsigned int
nco_gen(vspa_complex_float32 *pGain, // Pointer to complex gain
        vspa_complex_float32 *pOut,  // Output buffer pointer for holding single precision floating point complex values
        int freq,                    // Mixer frequency
        int phase                    // Mixer phase
);

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int test_type;
    int freq, phase, delta_freq;
    vspa_complex_float32 *opbuf_ptr;

    host_reset();

    test_type = config_buffer[0];
    delta_freq = config_buffer[1];
    freq = mixerParams.mxrFreq;
    phase = mixerParams.mxrPhase;
    gain_buffer[0] = mixerParams.rxGain;

    opbuf_ptr = output_buffer;
    if (test_type == 1) {
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;

        mixerParams.mxrFreq = freq;
        mixerParams.mxrPhase = phase;
        freq_phase_update(&mixerParams, delta_freq);
        freq = mixerParams.mxrFreq;
        phase = mixerParams.mxrPhase;
        gain_buffer[0] = mixerParams.rxGain;

        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
    } else if (test_type == 2) {
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;

        mixerParams.mxrFreq = freq;
        mixerParams.mxrPhase = phase;
        freq_phase_update2(&mixerParams, delta_freq);
        freq = mixerParams.mxrFreq;
        phase = mixerParams.mxrPhase;
        gain_buffer[0] = mixerParams.rxGain;

        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
        phase = nco_gen(gain_buffer, opbuf_ptr, freq, phase);
        opbuf_ptr += 128;
    }

    __asm("fnop;");
    __asm("fnop;");

    __swbreak();
    __builtin_done();
}
