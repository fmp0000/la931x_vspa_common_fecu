// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           atan_alloc.c
//! @brief          ATAN library source file.
//! @author         NXP Semiconductors.
//!
//! The atan_alloc.c allocates the polynomial coefficient buffer.
// =============================================================================

#include "atan.h"

// -----------------------------------------------------------------------------
//! @brief      Polynomial coefficient buffer used for the polynomial fitting
//!             approximation of atan(x) in the interval x : [-1,1].
//! @attention  This buffer is NOT required to be vector aligned.
//! @note       Each coefficient value is duplicated in order to use the VSPA
//!             S2mode = "S2i1r1i1r1" in order to load entire S2 register with
//!             one coefficient.
// -----------------------------------------------------------------------------
const uint32_t ATAN2_COEFF_BUFF[2 * ATAN2_NUM_COEFF] = {
#include "atan_coeff.txt"
};
