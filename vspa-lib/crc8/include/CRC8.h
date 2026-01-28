// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file       CRC8.h
//! @brief      Functions for bitwise 8 bits CRC calculation.
//! @author     NXP Semiconductors
// =============================================================================
#include "stdint.h"

// -----------------------------------------------------------------------------
//!
//! The CRC8 Library performs bit-wise CRC-8 generation for an input sequence of size
//!    - 20 bits
//!    - 21 bits
//!    - 23 bits
//!    - 34 bits
//! The CRC8 library uses the generator polynomial D^8 + D^2 + D + 1
//! @{
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// variable
// -----------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//! @brief           8-bit bit-wise CRC generation
//!
//! @param[in]       data1		Least significant 32 bits of the input data steam
//! @param[in]       data2 		most significant bits of the input data steam (only used id size=32)
//! @param[in]       size       size of input data stream in bits (20, 21, 23, or 34)
//! @param[out]      crc_out 	Output 8 bits crc
//! @return          Void.
//! @cycle
//! @stack         	 0
//!

// ---------------------------------------------------------------------------
extern uint_fast8_t crc8_encode(uint32_t data1,   // input data
                                uint32_t data2,   // input data if size of data is more than 32 bits
                                uint_fast8_t size // size of the input data in bits
);
