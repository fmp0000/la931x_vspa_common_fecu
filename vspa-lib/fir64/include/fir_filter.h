// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2022 - 2025  NXP

#ifndef FIR_FILTERS_H_
#define FIR_FILTERS_H_

/*
API:
        void fir_filter(__fx16 *output , __fx16 *input, unsigned int num_samples, __fx16* history, float* filter_taps);
        void fir_filter_circ(__fx16 *output , __fx16 *input, unsigned int num_samples, float* filter_taps, void* circ_base, unsigned
int circ_size_byte);

Arguments:
        output:      the output samples buffer, aligned to 128 bytes
        input:       the input samples buffer, aligned to 128 bytes, input and output can be same buffer.
        history:     history buffer, aligned to 128 bytes, must be in size defined by SIZE_HISTORY, should be cleared to 0 at
initialization stage (one time) filter_taps: filter taps coefficient buffer, aligned to 128 bytes, must be in size defined by any of
the following Macros for example SIZE_X4_INTERP_TAP64_FILTER_TAPS. num_samples: (For VSPA3):multiple of 128 samples, minimum 128
samples (For VSPA2):multiple of 32 samples, minimum 128 samples
*/

// For VSPA2, this value must be >= 40 and <= 64,  this is the only value users can configure
// For VSPA3, this value must be 63
#define NUM_FIR_TAPS 63

#define SIZE_FIR_HISTORY 256
#define SIZE_FIR_FILTER_TAPS (NUM_FIR_TAPS * 4)

#ifndef FILTER_DEF_ONLY
void fir_filter(__fx16 *output, __fx16 *input, unsigned int num_samples, __fx16 *history, float *filter_taps);
void fir_filter_circ(__fx16 *output, __fx16 *input, unsigned int num_samples, float *filter_taps, void *circ_base,
                     unsigned int circ_size_byte);
#endif

/* Example of using the filter APIs

#include "fir_filter.h"
#define NUM_INPUT_SAMPLES		2048
int history_buffer[SIZE_FIR_HISTORY/4]__attribute__ ((aligned (128)));
float filter_taps[SIZE_FIR_FILTER_TAPS/4]__attribute__ ((aligned (128)));  //max 64 taps
unsigned int input[NUM_INPUT_SAMPLES]__attribute__ ((aligned (128)));
unsigned int output[NUM_INPUT_SAMPLES]__attribute__ ((aligned (128)));

fir_filter((__fx16*)output, (__fx16*)input, NUM_INPUT_SAMPLES, (__fx16*)history_buffer, filter_taps);
or:
fir_filter((__fx16*)input, (__fx16*)input, NUM_INPUT_SAMPLES, (__fx16*)history_buffer, filter_taps);
 *
 */

#endif
