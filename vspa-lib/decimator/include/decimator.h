// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           decimator.h
//! @brief          DECIMATOR library interface definitions.
//! @author         NXP Semiconductors.
//! @ingroup        GROUP_DECIM
//!
//! The decimator.h header defines the FIR DECIMATOR library application programming
//! interface.
// =============================================================================

#ifndef __DECIMATOR__
#define __DECIMATOR__

#include "vspa.h"

// -----------------------------------------------------------------------------
//! @defgroup       GROUP_DECIM Decimator Library
//! @brief          FIR Decimator function library
//!
//! This library contains function prototypes for the following FIR Decimator kernels:
//!      - decimator_2x_32hf()
//!      - decimator_2x_x32hf()
//!      - decimator_4x_32hf()
//!      - decimator_4x_x32hf()
//!      - decimator_8x_32hf()
//!      - decimator_8x_x32hf()
//! @{
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              DEFINES
// -----------------------------------------------------------------------------
#define DECIM_FACT_2X 2
#define DECIM_FACT_4X 4
#define DECIM_FACT_8X 8

#define DECIM_NUM_INP_BUFFERS 2 /* Number of input buffers (double buffering).                      */
#define DECIM_SAMP_PER_LINE 32  /* Number of input/output samples per DMEM line                     */

#define DECIM_MIN_FLT_LEN 16 /* Minimum filter length.                                           */
#define DECIM_MAX_FLT_LEN 32 /* Maximum filter length.                                           */
#define DECIM_FLT_LEN 16     /* Current (used) filter length. FORINT: change to desired length.  */

#define DECIM_MIN_OUT_LINES 1 /* Minimum number of output lines.                                  */
//#define DECIM_MAX_OUT_LINES      4      /* Maximum number of output lines. FORINT: change to desired value. */
#define DECIM_MAX_OUT_LINES 2 /* Maximum number of output lines. FORINT: change to desired value. */

// -----------------------------------------------------------------------------
//                             TYPEDEFS
// -----------------------------------------------------------------------------
#if !defined(__ASSEMBLER__)
// -----------------------------------------------------------------------------
//! @brief      Persistent memory type for 4x Decimator which holds the history
//!             of the intermediate stage (the output history of first 2x decimator).
//! @attention  The integrator will NOT reuse this memory.
//! @attention  For the FIRST ever kernel call (e.g. at system init) the integrator
//!             must make sure the persistent buffers are cleared (set to '0').
// -----------------------------------------------------------------------------
typedef cfixed16_t DECIM_4X_PERSIST_MEM_T[DECIM_SAMP_PER_LINE] _VSPA_VECTOR_ALIGN;

// -----------------------------------------------------------------------------
//! @brief      Persistent memory type for 8x Decimator which holds the history
//!             of the intermediate stages (the output history of first and second 2x decimator).
//! @attention  The integrator will NOT reuse this memory.
//! @attention  For the FIRST ever kernel call (e.g. at system init) the integrator
//!             must make sure the persistent buffers are cleared (set to '0').
// -----------------------------------------------------------------------------
typedef cfixed16_t DECIM_8X_PERSIST_MEM_T[2 * DECIM_SAMP_PER_LINE] _VSPA_VECTOR_ALIGN;

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 2x FIR Decimator in assembly for 32
//!               complex half-fixed output samples (1 DMEM line).
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void decimator_2x_32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, size_t inp_circ_size);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 2x FIR Decimator in assembly for
//!               N x 32 complex half-fixed output samples (N x output DMEM lines)
//!               with N >= 2.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void decimator_2x_x32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, size_t inp_circ_size, uint32_t num_out_lines);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 4x FIR Decimator in assembly for 32
//!               complex half-fixed output samples (1 DMEM line).
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_4x_32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_4X_PERSIST_MEM_T *persist_p,
                       size_t inp_circ_size);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 4x FIR Decimator in assembly for
//!               N x 32 complex half-fixed output samples (N x output DMEM lines)
//!               with N >= 2.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_4x_x32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_4X_PERSIST_MEM_T *persist_p,
                        size_t inp_circ_size, uint32_t num_out_lines);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 8x FIR Decimator in assembly for 32
//!               complex half-fixed output samples (1 DMEM line).
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_8x_32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_8X_PERSIST_MEM_T *persist_p,
                       size_t inp_circ_size);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 8x FIR Decimator in assembly for
//!               N x 32 complex half-fixed output samples (N x output DMEM lines)
//!               with N >= 2.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_8x_x32hf(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_8X_PERSIST_MEM_T *persist_p,
                        size_t inp_circ_size, uint32_t num_out_lines);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 2x FIR Decimator in C code with VSPA
//!               intrinsics.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel does NOT use scratch memory.
// ---------------------------------------------------------------------------
void decimator_2x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, size_t inp_circ_size, uint32_t num_out_lines);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 4x FIR Decimator in C code with VSPA
//!               intrinsics.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_4x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_4X_PERSIST_MEM_T *persist_p,
                    size_t inp_circ_size, uint32_t num_out_lines);

// ---------------------------------------------------------------------------
//! @brief        This kernel implements a 8x FIR Decimator in C code with VSPA
//!               intrinsics.
//!
//! @param[in]    inp_p          Input pointer within the input circular buffer.
//! @param[out]   out_p          Output buffer pointer.
//! @param[in]    inp_circ_p     Input circular buffer start address.
//! @param[in]    persist_p      Persistent memory buffer.
//! @param[in]    inp_circ_size  Input circular buffer size (in half-words).
//! @param[in]    num_out_lines  Number of output lines (minimum 2).
//! @return       void
//!
//! @attention    The input circular buffer must be vector-aligned.
//! @attention    The persistent buffer must be vector-aligned.
//! @attention    The output buffer must be vector-aligned.
//!
//! @note         This kernel uses scratch memory to store intermediate data.
// ---------------------------------------------------------------------------
void decimator_8x_c(cfixed16_t *inp_p, cfixed16_t *out_p, cfixed16_t *inp_circ_p, DECIM_8X_PERSIST_MEM_T *persist_p,
                    size_t inp_circ_size, uint32_t num_out_lines);

#endif // !defined( __ASSEMBLER__ )
//! @} GROUP_DECIM

// -----------------------------------------------------------------------------
//! @brief   Section to overwrite filter length macro - TESTING ONLY!
//! FORINT   Ignore this section and make sure is NOT activated during integration!
// -----------------------------------------------------------------------------
#ifdef TEST_DECIM_FLT_LEN
#undef DECIM_FLT_LEN
#define DECIM_FLT_LEN TEST_DECIM_FLT_LEN
#endif

#endif // __DECIMATOR__
