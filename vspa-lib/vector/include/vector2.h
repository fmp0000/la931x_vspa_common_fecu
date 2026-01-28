// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file       vector2.h
//! @brief      Functions for vector linear algebra functions.
//! @author     NXP Semiconductors
// =============================================================================

#ifndef __VECTOR2_H__
#define __VECTOR2_H__

#include "vspa.h"

// ================================ y = x*a ) ============================================== //
//! @brief      Vector x Scalar: Implements y = y = x*a
//!				Where y, x are half-float complex vectors, a is single precision complex scalar.
//!
//! @param[in]  py          Pointer to output buffer. Must be DMEM line aligned. In complex 16-bit floating point.
//! @param[in]  px          Pointer to input vector, x. In complex 16-bit floating point.
//! @param[in]  pa          Pointer to input scalar, a. In complex 32-bit floating point.
//! @param[in]  L           Number of pairs of input DMEM lines. For an input buffer of size N, set L = ceil(N/64)
//! @stack      none
//!
//! @CycleCount Assembly version:   17+4*L cycles
// ==========================================================================================
extern void chp_chp_csp_vMultiSclr(cfloat16_t *py, cfloat16_t *px, vspa_complex_float32 *pa, size_t L);

#endif // __VECTOR2_H__
