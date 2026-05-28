// SPDX-License-Identifier: BSD-3-Clause
// compute_decim_2x_8tap.c — compute-mode harness for decimator_2x_8_Taps_asm
//
// Reads N_IN=2048 complex SM16 samples from input_td.bin,
// runs the 2x 8-tap decimator, then dumps 1024 samples
// to stdout for vspa_runner.py compute() mode.
//
// Build: make -C tests/resample_ddc_interp compute_decim_2x_8tap
//
// Filter taps are the 2xdown_coeff coefficients from DFE_ref.

#include <stdio.h>
#include <stdint.h>
#include "test_utils.h"

/* ── config ─────────────────────────────────────────────────────────────── */
#define N_IN         2088
#define N_OUT        1044     /* N_IN / 2 */
#define NUM_TAPS     8
#define STATE_LEN    32       /* cfixed16_t samples, 128-byte aligned */

/* Forward-declare the SX kernel (linked from ddc2x4x.sx) */
extern void decimator_2x_8_Taps_asm(void *pOut, void *pIn, float *pTaps,
                                    void *filtState, unsigned int n_samples);

/* Embedded filter taps — 2xdown_coeff.txt (natural order, symmetric) */
static const uint32_t filter_taps_u32[NUM_TAPS] = {
    0xBE0263BE, 0xBDE8A4F0, 0x3EA45618, 0x3F5B3BFF,
    0x3F5B3BFF, 0x3EA45618, 0xBDE8A4F0, 0xBE0263BE
};

/* Buffers — must be 128-byte aligned for VSPA vector loads */
_VSPA_VECTOR_ALIGN static uint32_t input_td[N_IN];
_VSPA_VECTOR_ALIGN static uint32_t state_buf[STATE_LEN];
_VSPA_VECTOR_ALIGN static uint32_t output_td[N_OUT];

/* ── main ───────────────────────────────────────────────────────────────── */
int main(void)
{
    int i;
    FILE *fp;

    /* Read input from binary file at runtime */
    fp = fopen("input_td.bin", "rb");
    if (!fp) {
        printf("FAIL: cannot open input_td.bin\n");
        return 1;
    }
    if (fread(input_td, sizeof(uint32_t), N_IN, fp) != (size_t)N_IN) {
        printf("FAIL: short read on input_td.bin\n");
        fclose(fp);
        return 1;
    }
    fclose(fp);

    /* Zero filter state for independent-symbol cosim */
    for (i = 0; i < STATE_LEN; i++)
        state_buf[i] = 0;

    /* Run 2x decimation */
    decimator_2x_8_Taps_asm((void *)output_td,
                            (void *)input_td,
                            (float *)filter_taps_u32,
                            (void *)state_buf,
                            N_IN);

    /* Write output binary */
    fp = fopen("output_td.bin", "wb");
    if (fp) {
        fwrite(output_td, sizeof(uint32_t), N_OUT, fp);
        fclose(fp);
        printf("VSPA_OUT_BIN output_td output_td.bin %d\n", N_OUT);
    } else {
        printf("FAIL: cannot open output_td.bin\n");
        return 1;
    }

    return 0;
}
