// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "sigcond.h"
#include "sigcond2.h"

//======================================================================================================
// Global variables (global names should be prepended with subsystem or "main_" prefix)
//======================================================================================================

//======================================================================================================
// Main local variables and types  (variables should be declared static)
//======================================================================================================
vspa_complex_fixed16 input_buffer[8192] __attribute__((aligned(64)));
vspa_complex_fixed16 output_buffer[8192] __attribute__((aligned(64)));
vspa_complex_fixed16 tempoutput_buffer[4096] __attribute__((aligned(64)));
structSigCondParams sigcondcfg_struct __attribute__((aligned(64)));
vspa_complex_fixed16 customsigcond_ScratchMem[2592] __attribute__((aligned(64)));

unsigned int config_buffer[4];

vspa_pair_fixed16 customsigcond_FilterTaps[13];

//======================================================================================================
// Definition of global assembly functions
//======================================================================================================

//======================================================================================================
// Public (externally visible) functions
//======================================================================================================

//----------------------------------------------------------------------------------------------------
__attribute__((noreturn)) void main(void) {
    unsigned int batch_size, batch_size_hw, n_batches, bw, i, input_offset, output_offset, type, n_iter, output_sz;
    vspa_complex_fixed16 *input_ptr;
    vspa_complex_fixed16 *output_ptr;
    void (*customsigcondfnptr)(vspa_complex_fixed16 const *, vspa_complex_fixed16 *, structSigCondParams *); // function pointer

    host_reset();

    batch_size = config_buffer[0];
    bw = config_buffer[1];
    n_batches = config_buffer[2];
    type = config_buffer[3];

    sigcondcfg_struct.inCircBuffBase = input_buffer;

    if (type <= 10) {
#if CUSTOMSIGCOND_IQSSFILT_NUMTAPS == 4
        if (batch_size == 640) {
            if (bw == 80) {
                customsigcondfnptr = customsigcond_ddc2x_N640_4t;
                input_offset = 640;
                output_offset = 320;
            } else if (bw == 40) {
                customsigcondfnptr = customsigcond_ddc4x_N640_4t;
                input_offset = 640;
                output_offset = 160;
            } else if (bw == 20) {
                customsigcondfnptr = customsigcond_ddc8x_N640_4t;
                input_offset = 640;
                output_offset = 96;
            }
        } else if (batch_size == 576) {
            if (bw == 80) {
                customsigcondfnptr = customsigcond2_ddc2x_N576_5t;
                input_offset = 576;
                output_offset = 288;
            } else if (bw == 40) {
                customsigcondfnptr = customsigcond2_ddc4x_N576_5t;
                input_offset = 576;
                output_offset = 160;
            }
        } else if (batch_size == 256) {
            if (bw == 80) {
                customsigcondfnptr = customsigcond_ddc2x_N256_4t;
                input_offset = 256;
                output_offset = 128;
            } else if (bw == 40) {
                customsigcondfnptr = customsigcond_ddc4x_N256_4t;
                input_offset = 256;
                output_offset = 64;
            } else if (bw == 20) {
                customsigcondfnptr = customsigcond_ddc8x_N256_4t;
                input_offset = 256;
                output_offset = 32;
            }
        } else if (batch_size == 2560) {
            if (bw == 160) {
                customsigcondfnptr = customsigcond_ddc1x_N2560_4t;
                input_offset = 2560;
                output_offset = 2560;
            } else if (bw == 80) {
                customsigcondfnptr = customsigcond_ddc2x_N2560_4t;
                input_offset = 2560;
                output_offset = 1280;
            }
        } else if (batch_size == 1152) {
            if (bw == 160) {
                customsigcondfnptr = customsigcond_ddc1x_N1152_4t;
                input_offset = 1152;
                output_offset = 1152;
            }
        }

#elif CUSTOMSIGCOND_IQSSFILT_NUMTAPS == 5
        if (batch_size == 640) {
            if (bw == 80) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc2x_N640_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc2x_N640_5t;
                input_offset = 640;
                output_offset = 320;
            } else if (bw == 40) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc4x_N640_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc4x_N640_5t;
                input_offset = 640;
                output_offset = 160;
            } else if (bw == 20) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc8x_N640_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc8x_N640_5t;
                input_offset = 640;
                output_offset = 96;
            }
        } else if (batch_size == 576) {
            if (bw == 80) {
                customsigcondfnptr = customsigcond2_ddc2x_N576_5t;
                input_offset = 576;
                output_offset = 288;
            } else if (bw == 40) {
                customsigcondfnptr = customsigcond2_ddc4x_N576_5t;
                input_offset = 576;
                output_offset = 160;
            }
        } else if (batch_size == 256) {
            if (bw == 80) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc2x_N256_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc2x_N256_5t;
                input_offset = 256;
                output_offset = 128;
            } else if (bw == 40) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc4x_N256_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc4x_N256_5t;
                input_offset = 256;
                output_offset = 64;
            } else if (bw == 20) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc8x_N256_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc8x_N256_5t;
                input_offset = 256;
                output_offset = 32;
            }
        } else if (batch_size == 2560) {
            if (bw == 160) {
                customsigcondfnptr = customsigcond_ddc1x_N2560_5t;
                input_offset = 2560;
                output_offset = 2560;
            } else if (bw == 80) {
                if (type == 1)
                    customsigcondfnptr = customsigcond_ddc2x_N2560_5t;
                else
                    customsigcondfnptr = customsigcond2_ddc2x_N2560_5t;
                input_offset = 2560;
                output_offset = 1280;
            }
        } else if (batch_size == 1152) {
            if (bw == 160) {
                customsigcondfnptr = customsigcond_ddc1x_N1152_5t;
                input_offset = 1152;
                output_offset = 1152;
            }
        }

        // call custom chain
        for (i = 0; i < n_batches; i++) {
            if ((i & 1) == 0) {
                input_ptr = input_buffer;
                output_ptr = output_buffer;
                customsigcondfnptr(input_ptr, output_ptr, &sigcondcfg_struct);

                batch_size = config_buffer[0]; // pseudo instruction to make sure last store from function call finishes
                __swbreak();
            } else {
                input_ptr = input_buffer + input_offset;
                output_ptr = output_buffer + output_offset;
                customsigcondfnptr(input_ptr, output_ptr, &sigcondcfg_struct);

                batch_size = config_buffer[0]; // pseudo instruction to make sure last store from function call finishes
                __swbreak();
            }
        }

#endif
    }

    __builtin_done();
}
