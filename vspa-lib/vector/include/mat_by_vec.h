// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2018 - 2025   NXP Semiconductors

// =============================================================================
//! @file       mat_by_vec.h
//! @brief      Functions for matrix multiplication by a vector.
//! @author     NXP Semiconductors
// =============================================================================
#include <stdint.h>
#include <vspa/intrinsics.h>
#include "vspa.h"

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In complex 16-bit half-fixed.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfx_chfx_chfx(vspa_complex_fixed16 *py, vspa_complex_fixed16 const *px, vspa_complex_fixed16 const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In complex 16-bit half-float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfx_chfx_chfl(vspa_complex_fixed16 *py, vspa_complex_fixed16 const *px, vspa_complex_float16 const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 16-bit half-fixed.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfx_chfx_rhfx(vspa_complex_fixed16 *py, vspa_complex_fixed16 const *px, fixed16_t const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 16-bit half-float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfx_chfx_rhfl(vspa_complex_fixed16 *py, vspa_complex_fixed16 const *px, float16_t const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 32-bit float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfx_chfx_rfl(vspa_complex_fixed16 *py, vspa_complex_fixed16 const *px, float const *pa, uint32_t offset,
                                     uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-float.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In complex 16-bit half-fixed.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfl_chfx_chfx(vspa_complex_float16 *py, vspa_complex_fixed16 const *px, vspa_complex_fixed16 const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-float.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In complex 16-bit half-float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfl_chfx_chfl(vspa_complex_float16 *py, vspa_complex_fixed16 const *px, vspa_complex_float16 const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-float.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 16-bit half-fixed.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfl_chfx_rhfx(vspa_complex_float16 *py, vspa_complex_fixed16 const *px, fixed16_t const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-float.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 16-bit half-float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfl_chfx_rhfl(vspa_complex_float16 *py, vspa_complex_fixed16 const *px, float16_t const *pa,
                                      uint32_t offset, uint32_t L, uint32_t M);

// ---------------------------------------------------------------------------
//! @brief        VCPU module that multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
//!               i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
//!
//! @param[out]   py           Pointer to y.  DMEM aligned. In complex 16-bit half-float.
//!
//! @param[in]    px           Pointer to x1. DMEM aligned. In complex 16-bit half-fixed.
//!
//! @param[in]    pa           Pointer to a. In real 32-bit float.
//!
//!                            Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM
//!                            aligned
//!
//! @param[in]    L            The number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
//!
//! @param[in]    M            The number of entries in the input buffer a (which is equal to the number of xi vectors).
//!
// ---------------------------------------------------------------------------
extern void mat_by_vec_chfl_chfx_rfl(vspa_complex_float16 *py, vspa_complex_fixed16 const *px, float const *pa, uint32_t offset,
                                     uint32_t L, uint32_t M);
Binary file(standard input) matches
