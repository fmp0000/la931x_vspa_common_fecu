// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           matrix.h
//! @brief          Matrix library interface definitions.
//! @author         NXP Semiconductors.
//!
//! The matrix.h header defines the matrix library application programming interface.
// =============================================================================

#ifndef __MATRIX__
#define __MATRIX__

#include "vspa.h"

// ---------------------------------------------------------------------------
//! @brief        The batch multiplication kernels perform multiplication between:
//!                - a batch "vec" of D1 vectors  (each of size 1 x D2)
//!                - a batch "mat" of D1 matrices (each of size D3 x D2)
//!               resulting in a batch "out" of D1 vectors (each of size 1 x D3).
//!               The in-out relation is (^T denotes the transpose operator):
//!
//!                     out(k,:)^T = mat(k,:,:) * vec(k,:)^T     k = 1 ... D1
//!
//! @attention    Dimension order is storage order. All in/out data structures are assumed
//!               contiguously stored, without gaps between subsequent dimensions.
//!
//! @attention    Storage example for a 64 x 2 x 2 Complex Single Precision "mat" data
//!               with 16 samples per DMEM line (for VSPA 16AU), DMEM address increases
//!               from left to right and from top to bottom:
//!
//!               mat( 0, 0, 0), mat( 1, 0, 0), ..., mat(15, 0, 0)  <== DMEM line 0
//!               mat(16, 0, 0), mat(17, 0, 0), ..., mat(31, 0, 0)  <== DMEM line 1
//!               mat(32, 0, 0), mat(33, 0, 0), ..., mat(47, 0, 0)  <== DMEM line 2
//!               mat(48, 0, 0), mat(49, 0, 0), ..., mat(63, 0, 0)  <== DMEM line 3
//!
//!               mat( 0, 1, 0), mat( 1, 1, 0), ..., mat(15, 1, 0)  <== DMEM line 4
//!               mat(16, 1, 0), mat(17, 1, 0), ..., mat(31, 1, 0)  <== DMEM line 5
//!               mat(32, 1, 0), mat(33, 1, 0), ..., mat(47, 1, 0)  <== DMEM line 6
//!               mat(48, 1, 0), mat(49, 1, 0), ..., mat(63, 1, 0)  <== DMEM line 7
//!
//!               mat( 0, 0, 1), mat( 1, 0, 1), ..., mat(15, 0, 1)  <== DMEM line 8
//!               mat(16, 0, 1), mat(17, 0, 1), ..., mat(31, 0, 1)  <== DMEM line 9
//!               mat(32, 0, 1), mat(33, 0, 1), ..., mat(47, 0, 1)  <== DMEM line 10
//!               mat(48, 0, 1), mat(49, 0, 1), ..., mat(63, 0, 1)  <== DMEM line 11
//!
//!               mat( 0, 1, 1), mat( 1, 1, 1), ..., mat(15, 1, 1)  <== DMEM line 12
//!               mat(16, 1, 1), mat(17, 1, 1), ..., mat(31, 1, 1)  <== DMEM line 13
//!               mat(32, 1, 1), mat(33, 1, 1), ..., mat(47, 1, 1)  <== DMEM line 14
//!               mat(48, 1, 1), mat(49, 1, 1), ..., mat(63, 1, 1)  <== DMEM line 15
//!
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
//! @brief        Enumeration type for the return of the wrapper kernels.
// ---------------------------------------------------------------------------
typedef enum { MAT_BMULT_SUCCESS = 0, MAT_BMULT_ERROR } MAT_BMULT_RETURN_T;

// ---------------------------------------------------------------------------
//! @brief        This function is a wrapper over the individual kernels.
//!               This kernel performs batch multiplication with the following
//!               constraints:
//!               -> for D2 = 1 or 2 the dimension D1 is a multiple of 32 samples
//!               -> for D2 >= 3 the dimension D1 = 64
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x D2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples).
//! @param[in]    dim3    Dimension D3 of in/out data (in samples).
//! @return       Return MAT_BMULT_SUCCESS else MAT_BMULT_ERROR in case of invalid parameters.
//!
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
MAT_BMULT_RETURN_T mat_bmult_chfl_csp_chfl_c(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                             uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This function is a wrapper over the individual kernels.
//!               This kernel performs batch multiplication with the following
//!               constraints:
//!               -> for D2 = 1 or 2 the dimension D1 is a multiple of 32 samples
//!               -> for D2 >= 3 the dimension D1 = 64
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x D2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples).
//! @param[in]    dim3    Dimension D3 of in/out data (in samples).
//! @return       Return MAT_BMULT_SUCCESS else MAT_BMULT_ERROR in case of invalid parameters.
//!
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
MAT_BMULT_RETURN_T mat_bmult_chfx_csp_chfl_c(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                             uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size 64 x D2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size 64 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size 64 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples) with D2 >= 3.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 4/7 = 57%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_64xd2xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size 64 x D2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size 64 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size 64 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples) with D2 >= 3.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 4/7 = 57%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_64xd2xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x 2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x 2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 32.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 4/7 = 57%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_d1x2xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x 2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x 2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 32.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 4/7 = 57%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_d1x2xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x 1      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x 1 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 32.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 2/4 = 50%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_d1x1xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1 x 1      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1 x D3 x 1 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1 x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 32.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 2/4 = 50%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_d1x1xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

#pragma cplusplus on
static inline MAT_BMULT_RETURN_T mat_bmult(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                           uint32_t dim3) {
    return mat_bmult_chfl_csp_chfl_c(vec_p, mat_p, out_p, dim1, dim2, dim3);
}
static inline MAT_BMULT_RETURN_T mat_bmult(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                           uint32_t dim3) {
    return mat_bmult_chfx_csp_chfl_c(vec_p, mat_p, out_p, dim1, dim2, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_64xd2xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3) {
    mat_bmult_64xd2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
}
static inline void mat_bmult_64xd2xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3) {
    mat_bmult_64xd2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_d1x2xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_d1x2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
static inline void mat_bmult_d1x2xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_d1x2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_d1x1xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_d1x1xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
static inline void mat_bmult_d1x1xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_d1x1xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
// ... more functions can be added with different in/out data types.
#pragma cplusplus off

// ---------------------------------------------------------------------------
//! @brief        This function is a wrapper over the individual kernels.
//!               This kernel performs batch multiplication with matrix repetition
//!               order 4 with the following constraints:
//!               -> for D2 = 1 or 2 the dimension D1 is a multiple of 128 samples
//!               -> for D2 >= 3 the dimension D1 = 256
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x D2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples).
//! @param[in]    dim3    Dimension D3 of in/out data (in samples).
//! @return       Return MAT_BMULT_SUCCESS else MAT_BMULT_ERROR in case of invalid parameters.
//!
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
MAT_BMULT_RETURN_T mat_bmult_i4_chfl_csp_chfl_c(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1,
                                                uint32_t dim2, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This function is a wrapper over the individual kernels.
//!               This kernel performs batch multiplication with matrix repetition
//!               order 4 with the following constraints:
//!               -> for D2 = 1 or 2 the dimension D1 is a multiple of 128 samples
//!               -> for D2 >= 3 the dimension D1 = 256
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x D2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples).
//! @param[in]    dim3    Dimension D3 of in/out data (in samples).
//! @return       Return MAT_BMULT_SUCCESS else MAT_BMULT_ERROR in case of invalid parameters.
//!
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
MAT_BMULT_RETURN_T mat_bmult_i4_chfx_csp_chfl_c(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1,
                                                uint32_t dim2, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size 256 x D2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size  64 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size 256 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples) with D2 >= 3.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 100%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_256xd2xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2,
                                              uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size 256 x D2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size  64 x D3 x D2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size 256 x D3      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim2    Dimension D2 of in/out data (in samples) with D2 >= 3.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 100%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_256xd2xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2,
                                              uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x 2      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x 2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 128.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 100%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_d1x2xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x 2      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x 2 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 128.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 100%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_d1x2xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x 1      (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x 1 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 128.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 80%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_d1x1xd3_chfl_csp_chfl_asm(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

// ---------------------------------------------------------------------------
//! @brief        This kernel performs batch multiplication with matrix repetition order 4.
//!
//! @param[in]    vec_p   Pointer to input batch of complex vectors  with size D1   x 1      (16-bit complex half-fixed,
//! vector-aligned).
//! @param[in]    mat_p   Pointer to input batch of complex matrices with size D1/4 x D3 x 1 (32-bit complex single-precision,
//! vector-aligned).
//! @param[out]   out_p   Pointer to output batch of complex vectors with size D1   x D3     (16-bit complex half-float,
//! vector-aligned).
//! @param[in]    dim1    Dimension D1 of in/out data (in samples) with D1 multiple of 128.
//! @param[in]    dim3    Dimension D3 of in/out data (in samples) with D3 >= 1.
//! @return       void
//!
//! @note         The efficiency (ignoring calling overhead and assembly code preamble) is 80%.
//! @note         The computation cannot be perform in place: the output cannot overlap with one of the inputs.
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void mat_bmult_i4_d1x1xd3_chfx_csp_chfl_asm(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3);

#pragma cplusplus on
static inline MAT_BMULT_RETURN_T mat_bmult_i4(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                              uint32_t dim3) {
    return mat_bmult_i4_chfl_csp_chfl_c(vec_p, mat_p, out_p, dim1, dim2, dim3);
}
static inline MAT_BMULT_RETURN_T mat_bmult_i4(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim2,
                                              uint32_t dim3) {
    return mat_bmult_i4_chfx_csp_chfl_c(vec_p, mat_p, out_p, dim1, dim2, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_i4_256xd2xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3) {
    mat_bmult_i4_256xd2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
}
static inline void mat_bmult_i4_256xd2xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim2, uint32_t dim3) {
    mat_bmult_i4_256xd2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim2, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_i4_d1x2xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_i4_d1x2xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
static inline void mat_bmult_i4_d1x2xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_i4_d1x2xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
// ... more functions can be added with different in/out data types.

static inline void mat_bmult_i4_d1x1xd3(cfloat16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_i4_d1x1xd3_chfl_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
static inline void mat_bmult_i4_d1x1xd3(cfixed16_t *vec_p, cfloat32_t *mat_p, cfloat16_t *out_p, uint32_t dim1, uint32_t dim3) {
    mat_bmult_i4_d1x1xd3_chfx_csp_chfl_asm(vec_p, mat_p, out_p, dim1, dim3);
}
// ... more functions can be added with different in/out data types.
#pragma cplusplus off

#endif // __MATRIX__
