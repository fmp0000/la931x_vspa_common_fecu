// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2018 - 2025   NXP Semiconductors

// =============================================================================
//! @file       dft.h
//! @brief      DFT header file
//! @author     NXP Semiconductors
// =============================================================================

#ifndef __DFT__
#define __DFT__

#include "vspa.h"
// ---------------------------------------------------------------------------
//! @attention 	  Usecases - mini_dft_xx_xx_asm : Sequence length 2:96
//						   - dft_xx_xx_asm      : Sequence length >96
//
//----------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is in half fixed precision and output is in half
//! float precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n) 	 - input signal in time domain
//!                   N_DFT  – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (16-bit complex half-fixed, vector aligned).
//! @param[in]    scratch_p Pointer to scratch buffer (32-bit complex single, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (16-bit complex half-float, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        23 + (N_DFT-1) * ( 6*2 + 2 * ceil(N_DFT/16)) + 4 * ceil(N_DFT/32) + 3
//! @attention    The minimum DFT size (N_DFT) is 97.
//! @attention    Output buffer have to be an integer number of lines and the scratch buffer have to be an integer number of lines
//! double as the output buffer.
// ---------------------------------------------------------------------------
void dft_hfx_hfl_asm(cfixed16_t *in_p, cfloat32_t *scratch_p, cfloat16_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is single precision and output is half float
//! precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)   - input signal in time domain
//!                   N_DFT  – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (32-bit complex single, vector aligned).
//! @param[in]    scratch_p Pointer to scratch buffer (32-bit complex single, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (16-bit complex half-float, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        23 + (N_DFT-1) * ( 6*2 + 2 * ceil(N_DFT/16)) + 4 * ceil(N_DFT/32) + 3
//! @attention    The minimum DFT size (N_DFT) is 97.
//! @attention    Output buffer have to be an integer number of lines and the scratch buffer have to be an integer number of lines
//! double as the output buffer.
// ---------------------------------------------------------------------------
void dft_sfl_hfl_asm(cfloat32_t *in_p, cfloat32_t *scratch_p, cfloat16_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is half fixed precision and output is single
//! precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (16-bit complex half-fixed, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (32-bit complex single, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        22 + N_DFT * ( 6*2 + 2 * ceil(N_DFT/16)) + 3
//! @attention    The minimum DFT size (N_DFT) is 97.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void dft_hfx_sfl_asm(cfixed16_t *in_p, cfloat32_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is single precision and output is single precision.
//!				  The generic DFT has the following expression:
//!                    X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (32-bit complex single, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (32-bit complex single, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        22 + N_DFT * ( 6*2 + 2 * ceil(N_DFT/16)) + 3
//! @attention    The minimum DFT size (N_DFT) is 97.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void dft_sfl_sfl_asm(cfloat32_t *in_p, cfloat32_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is in half fixed precision and output is in half
//! float precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (16-bit complex half-fixed, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (16-bit complex half-float, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        19 +  8 + 3 + ((N_DFT - 2) * 7)  + 2 * (ceil (N_DFT / 16)
//! @attention    The minimum DFT size (N_DFT) is 3 and the maximum DFT size (N_DFT) is 96.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void mini_dft_hfx_hfl_asm(cfixed16_t *in_p, cfloat16_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is single precision and output is half float
//! precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (32-bit complex single, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (16-bit complex half-float, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        19 + 8 + 3 + ((N_DFT - 2) * 7)  + 2 * (ceil (N_DFT / 16)
//! @attention    The minimum DFT size (N_DFT) is 3 and the maximum DFT size (N_DFT) is 96.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void mini_dft_sfl_hfl_asm(cfloat32_t *in_p, cfloat16_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is half fixed precision and output is single
//! precision.
//!				  The generic DFT has the following expression:
//!                   X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (16-bit complex half-fixed, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (32-bit complex single, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        19 + 8 + 3 + ((N_DFT - 2) * 7)  + (ceil (N_DFT / 16)
//! @attention    The minimum DFT size (N_DFT) is 3 and the maximum DFT size (N_DFT) is 96.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void mini_dft_hfx_sfl_asm(cfixed16_t *in_p, cfloat32_t *out_p, uint32_t n_dft);

// ---------------------------------------------------------------------------
//! @brief        This module provides a kernel for a Generic DFT input. Input is single precision and output is single precision.
//!				  The generic DFT has the following expression:
//!                    X(k) = sum(n = 0 ; N_DFT - 1)( x(n) * exp(-j * 2 * pi * k * n / N_DFT)
//!               where:
//!                   x(n)  - input signal in time domain
//!                   N_DFT – input sequence length
//!
//! @param[in]    in_p    	Pointer to input buffer (32-bit complex single, vector aligned).
//! @param[out]   out_p   	Pointer to output buffer (32-bit complex single, vector aligned).
//! @param[in]    n_dft   	Sequence length (N_DFT) in samples.
//! @return       void
//! @cycle        19 + 8 + 3 + ((N_DFT - 2) * 7)  + (ceil (N_DFT / 16)
//! @attention    The minimum DFT size (N_DFT) is 3 and the maximum DFT size (N_DFT) is 96.
//! @attention    Output buffer have to be an integer number of lines.
// ---------------------------------------------------------------------------
void mini_dft_sfl_sfl_asm(cfloat32_t *in_p, cfloat32_t *out_p, uint32_t n_dft);

#endif // __DFT__
