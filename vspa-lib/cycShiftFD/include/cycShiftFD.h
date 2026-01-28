// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2018 - 2025   NXP Semiconductors

// =============================================================================
//! @file       cycShiftFD.h
//! @brief      Functions for cyclic Shift in frequency domain.
//! @author     NXP Semiconductors
// =============================================================================

#ifndef __cycShiftFD__
#define __cycShiftFD__

#include "vspa.h"

//! @brief      	Cyclic shift via elementwise vector multiplication in time domain: y = x.*m,
//!             	where x is the input signal in LINEAR buffer, m is an NCO-generated complex sequence, and y is the mixed
//!             signal in linear buffer.
//! @param[in]  	in_p        Pointer to input buffer (16-bit complex half precision, vector aligned).
//! @param[Out] 	out_p       Pointer to output buffer (16-bit complex half precision, vector aligned).
//! @param[in]  	shift 		Shift size (equivalent in time domain to number of elements for cyclic shift).
//! @param[in]  	length      Sequence length in samples.
//!
//! @attention  This function is the equivalent in time domain with cyclic shifting with N elements to the right.
//!
//! @CycleCount Assembly version:   37 + 2*L cycles 48% at L=8; 78% at L=31. 100% is upper limit of AUeff.)
//!                                 [21 25 33] cycles at L=[2 4 8]
//! @PMEMsize   Assembly version:   152 bytes (152 = 19 x 8)

void cycShiftFD_asm(cfloat16_t *in_p, cfloat16_t *out_p, int shift, int length);

#endif // __cycShiftFD__
