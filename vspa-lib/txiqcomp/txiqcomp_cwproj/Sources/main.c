// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "txiqcomp.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
vspa_complex_fixed16 input_buffer[2048] _VSPA_VECTOR_ALIGN;
vspa_complex_fixed16 output_buffer[2048] __align_vec __attribute__((section(".ibss")));
structTXIQCompParams txiqcompcfg_struct _VSPA_VECTOR_ALIGN;

structTXIQCompParams2 txiqcompcfg2_struct;

unsigned int config_buffer[4];

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int batch_size, n_batches, func_type, n_lines, i;
    float gain;
    vspa_complex_fixed16 *input_ptr;
    vspa_complex_fixed16 *output_ptr;

    batch_size = config_buffer[0];
    n_batches = config_buffer[1];
    func_type = config_buffer[2];
    gain = *(float *)(&config_buffer[3]);

    host_reset();

    if (2 == func_type) {
        txiqcompcfg2_struct.inpCircBuffBase = input_buffer;
        txiqcompcfg2_struct.inpCircBuffSize = 2 * batch_size * sizeof(vspa_complex_fixed16);

        /* Apply gain */
        txiqcomp_apply_gain(&txiqcompcfg2_struct.IQImb_ftaps, &txiqcompcfg2_struct, gain);
    }

    for (i = 0; i < n_batches; i++) {

        /* Double buffering */
        if ((i & 1) == 0) {
            input_ptr = input_buffer;
            output_ptr = output_buffer;
        } else {
            input_ptr = input_buffer + batch_size;
            output_ptr = output_buffer + batch_size;
        }

        n_lines = (batch_size >> 5);

        if (1 == func_type) {
            /* Type 1 function */
            txiqcomp(input_ptr, output_ptr, &txiqcompcfg_struct, n_lines);

        } else {
            /* Type 2 function */
            txiqcomp_x32chf_5t(input_ptr, output_ptr, &txiqcompcfg2_struct, n_lines);
        }

        batch_size = config_buffer[0]; // pseudo instruction to make sure last store from function call finishes
        __swbreak();
    }

    __builtin_done();
}
