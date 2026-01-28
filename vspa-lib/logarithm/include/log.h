// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           log.h
//! @brief          LOG library interface definitions.
//! @author         NXP Semiconductors.
// =============================================================================

#ifndef __LOG__
#define __LOG__

#include "vspa.h"

// ---------------------------------------------------------------------------
//! @brief        Logarithm factor enumeration type.
// ---------------------------------------------------------------------------
typedef enum {
    LOG2x1 = 0x3f800000,   // Logarithm factor to compute f(x) = log2(x)
    LOG10x10 = 0x4040A8C1, // Logarithm factor to compute f(x) = 10 * log10(x)
    LOG10x20 = 0x40c0a8c1, // Logarithm factor to compute f(x) = 20 * log10(x)
} LOG_FACT_T;

// ---------------------------------------------------------------------------
//! @brief      This function computes a general logarithm function:
//!                     y = f(x) = fact * log2(x)
//!             The following cases can be used:
//!                     fact = 1 for f(x) = log2(x)
//!                     fact = 10 * log10(2) for f(x) = 10 * log10(x)
//!                     fact = 20 * log10(2) for f(x) = 20 * log10(x)
//!
//! @param[in]  x     Input value (32-bit floating point Single Precision).
//! @param[in]  fact  Logarithm factor to compute desired function.
//!                   Choose value from enumeration type LOG_FACT_T.
//! @return     The logarithm value f(x) in 32-bit floating point Single Precision.
//! @cycle      25
//! @note       This function does NOT use persistent/scratch memory.
//! ---------------------------------------------------------------------------
float32_t log_asm(float32_t x, LOG_FACT_T fact);

#endif // __LOG__
