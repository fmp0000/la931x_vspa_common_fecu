// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// =============================================================================
//! @file           FD_QEC.h
//! @brief          FD_QEC library interface definitions.
//! @author         NXP Semiconductors.
//!
//! The BCC3RDPERM.h header defines the FD_QEC library application programming
//! interface.
// =============================================================================

#ifndef __FD_QEC__ /* Testcase parameters */
#define __FD_QEC__

#include "vspa.h"

// -----------------------------------------------------------------------------
//! @defgroup       GROUP FD_QEC Library
//! @brief          Frequency domain quadrature error correction function library
//!
//! This library contains function prototypes for the following  FD_QEC kernels:
//!     - fd_qec()
//! @{
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
//                             TYPEDEFS
// -----------------------------------------------------------------------------
#if !defined(__ASSEMBLER__)

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a bcc3rdperm in assembly for 2X
//!                80MHz output samples (234x2 words).
//! @param[out]   out             Output buffer pointer.
//! @param[in]    inp_p0          Input pointer 0 within the first input buffer.
//! @param[in]    inp_p1          Input pointer 1 within the second input buffer.
//! @param[in]    inp_p2          Input pointer 2 within the weights buffer.
//! @param[in]    size            Input circular buffer size (in samples).
//! @return       void
//!
//! Cycles: size/32*6+37
//!
//! @attention    The output size is fixed to
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel does NOT operate in place.
// ---------------------------------------------------------------------------
void fd_qec(cfixed16_t *out_p, cfixed16_t *inp_p0, cfixed16_t *inp_p1, cfixed16_t *inp_p2, uint32_t offset);

#endif // !defined( __ASSEMBLER__ )

#endif // __FD_QEC__
