// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

#pragma optimization_level 0
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "vector.h"

#define L_MAX 8 // number of output DMEM lines

__fx16 add_y_rhf[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fx16 multi_y_rhf[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fx16 x_rhf[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fx16 alpha_rhf[3] _VSPA_VECTOR_ALIGN;

__fp16 add_y_rhp[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fp16 multi_y_rhp[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fp16 x_rhp[L_MAX * (__AU_COUNT__ * 4)] _VSPA_VECTOR_ALIGN;
__fp16 alpha_rhp[3] _VSPA_VECTOR_ALIGN;

float add_y_rsp[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
float multi_y_rsp[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
float x_rsp[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
float alpha_rsp[3] _VSPA_VECTOR_ALIGN;

cfixed16_t add_y_chf[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
cfixed16_t x_chf[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
cfixed16_t alpha_chf[3] _VSPA_VECTOR_ALIGN;

cfloat16_t add_y_chp[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
cfloat16_t x_chp[L_MAX * (__AU_COUNT__ * 2)] _VSPA_VECTOR_ALIGN;
cfloat16_t alpha_chp[3] _VSPA_VECTOR_ALIGN;

vspa_complex_float32 add_y_csp[L_MAX * (__AU_COUNT__)] _VSPA_VECTOR_ALIGN;
vspa_complex_float32 x_csp[L_MAX * (__AU_COUNT__)] _VSPA_VECTOR_ALIGN;
vspa_complex_float32 alpha_csp[3] _VSPA_VECTOR_ALIGN;

size_t L = 0;

void main(void) {

    vAddSclr(add_y_rhf, x_rhf, &alpha_rhf[1], L);
    vAddSclr(add_y_rhp, x_rhp, &alpha_rhp[1], L);
    vAddSclr(add_y_rsp, x_rsp, &alpha_rsp[1], L);
    vAddSclr(add_y_chf, x_chf, &alpha_chf[1], L);
    vAddSclr(add_y_chp, x_chp, &alpha_chp[1], L);
    vAddSclr(add_y_csp, x_csp, &alpha_csp[1], L);

    vMultiSclr(multi_y_rhf, x_rhf, &alpha_rsp[1], L);
    vMultiSclr(multi_y_rhp, x_rhp, &alpha_rsp[1], L);
    vMultiSclr(multi_y_rsp, x_rsp, &alpha_rsp[1], L);

    __nop();
    __nop();
    __swbreak();
    __builtin_done();
}
