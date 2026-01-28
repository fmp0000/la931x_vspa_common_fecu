// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           matrix_bmult_c.c
//! @brief          Batch multiplication C source file
//! @author         NXP Semiconductors.
// =============================================================================

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>
#include <time.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "matrix.h"

MAT_BMULT_RETURN_T mat_bmult_i4_chfl_csp_chfl_c(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1,
                                                uint32_t dim2, uint32_t dim3) {
    switch (dim2) {
    case 1:
        mat_bmult_i4_d1x1xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
        break;
    case 2:
        mat_bmult_i4_d1x2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
        break;
    default:
        if (dim1 != 256)
            return MAT_BMULT_ERROR;
        mat_bmult_i4_256xd2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
    }
    return MAT_BMULT_SUCCESS;
}

MAT_BMULT_RETURN_T mat_bmult_i4_chfx_csp_chfl_c(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1,
                                                uint32_t dim2, uint32_t dim3) {
    switch (dim2) {
    case 1:
        mat_bmult_i4_d1x1xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
        break;
    case 2:
        mat_bmult_i4_d1x2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
        break;
    default:
        if (dim1 != 256)
            return MAT_BMULT_ERROR;
        mat_bmult_i4_256xd2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
    }
    return MAT_BMULT_SUCCESS;
}
