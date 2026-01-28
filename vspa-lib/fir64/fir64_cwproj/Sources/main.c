// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "fir_filter.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
#define NUM_INPUT_SAMPLES 2048
int history_buffer[SIZE_FIR_HISTORY / 4] __attribute__((aligned(128)));
float filter_taps[SIZE_FIR_FILTER_TAPS / 4] __attribute__((aligned(128))); // max 64 taps
unsigned int input[NUM_INPUT_SAMPLES] __attribute__((aligned(128)));
unsigned int output[NUM_INPUT_SAMPLES] __align_vec __attribute__((section(".ibss")));

unsigned int config_buffer[4];

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int datSz;

    host_reset();

    datSz = NUM_INPUT_SAMPLES; // config_buffer[0];

    fir_filter((__fx16 *)output, (__fx16 *)input, NUM_INPUT_SAMPLES, (__fx16 *)history_buffer, filter_taps);

    __swbreak();
    __builtin_done();
}
