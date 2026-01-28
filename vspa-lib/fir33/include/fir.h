// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025 copy  NXP Semiconductor

// ===========================================================================
//! @file            fir.h
//! @copyright       &copy; 2017 NXP Semiconductor
//! @ingroup         GROUP_FIR
//! @brief           FIR library interface definitions.
//!
//! The fir.h header defines the FIR library application programming
//! interface.
//!
//! This header declares function prototypes for 16-bit fixed-point
//! FIR operation
//!
//! @defgroup        GROUP_FIR FIR Library
//!
//! The FIR Library provides the following filtering functions:
//!   - FIR Filter:
//!      - firFilterReal(): FIR Filter with real taps in 16-bit fixed-point
//!
//! @{
// ===========================================================================

#ifndef __FIR_H__
#define __FIR_H__

#include <stddef.h>

// ---------------------------------------------------------------------------
//! @brief           FIR filter with real taps. Supports L = 12 to 33. Half-fixed precision.
//!
//! @param[in]       pIn   	Input pointer pointing to data sample x(0)
//! @param[out]      pOut  	Output buffer address
//! @param[in]       pTaps 	Pointer to filters taps. Taps must be arranged in the following way (left to right is LS to MS)
//!							[h(L-1) h(L-2) h(L-3) ... h(1) h(0)]
//! @param[in]       itDat 	Iteration count for data size. For data vector of size, M, set itDat = ceil(M/64)
//! @param[in]       itTaps Iteration count for number of taps. For number of taps L, set itTaps = L-11
//! @return          Void.
//!
//! This function implements FIR filter for complex data with real taps.
//!	Input/output data are in half-fixed precision.
//!
//!
//! @attention       This function can operate in-place.
//! @attention       The output buffer must be vector-aligned.
// ---------------------------------------------------------------------------
extern void firFilterReal(cfixed16_t *pIn,    // Circular input buffer pointer for holding half-fixed precision complex values
                          cfixed16_t *pOut,   // Output buffer pointer for holding half-fixed precision complex values.
                          fixed16_t *pTaps,   // Filter taps buffer
                          unsigned int itDat, // Iterations for data size
                          unsigned int itTaps // Iterations for number of taps
);

#endif // __FIR_H__

//! @} GROUP_FIR
