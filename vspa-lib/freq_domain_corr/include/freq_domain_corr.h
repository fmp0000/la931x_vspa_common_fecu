// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file           freq_domain_corr.h
//! @brief          Frequency domain correction library interface definitions.
//! @author         NXP Semiconductors.
// =============================================================================

#ifndef __FREQ_DOMAIN_CORR__
#define __FREQ_DOMAIN_CORR__

#include "vspa.h"

// ---------------------------------------------------------------------------
//                              DEFINES
// ---------------------------------------------------------------------------
// Number of sub carriers per DMEM line
#define FREQ_DOMAIN_CORR_NUM_SBC_PER_LINE 32

// Defines for 11ac @ 20MHz, full BW processing (SISO or MIMO)
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_20MHz_FULL -28

// Defines for 11ac @ 40MHz, full BW processing (SISO) or half BW processing (MIMO)
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_40MHz_FULL -58
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_40MHz_HALF0 -58
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_40MHz_HALF1 6

// Defines for 11ac @ 80MHz, full BW processing (SISO) or quarter BW processing (MIMO)
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_80MHz_FULL -122
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_80MHz_QUART0 -122
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_80MHz_QUART1 -58
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_80MHz_QUART2 6
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ac_80MHz_QUART3 70

// Defines for 11ax @ 80MHz, full BW processing (SISO) or quarter BW processing (MIMO)
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ax_80MHz_996RU_FULL -500
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ax_80MHz_996RU_QUART0 -500
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ax_80MHz_996RU_QUART1 -244
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ax_80MHz_996RU_QUART2 12
#define FREQ_DOMAIN_CORR_PHASE_INIT_11ax_80MHz_996RU_QUART3 268

// Number of DMEM lines per stream for each kernel
// These values can be used for scratch memory allocation (number of DMEM lines)
#define FREQ_DOMAIN_CORR_NUM_LINES_64SBC 2
#define FREQ_DOMAIN_CORR_NUM_LINES_128SBC 4
#define FREQ_DOMAIN_CORR_NUM_LINES_256SBC 8
#define FREQ_DOMAIN_CORR_NUM_LINES_512SBC 16
#define FREQ_DOMAIN_CORR_NUM_LINES_1024SBC 32

// DMEM allocation offset (in half-words) between subsequent streams for each kernel
// These values can be changed according to stream allocation in DMEM
#define FREQ_DOMAIN_CORR_STREAM_OFF_64SBC 2 * 64
#define FREQ_DOMAIN_CORR_STREAM_OFF_128SBC 4 * 64
#define FREQ_DOMAIN_CORR_STREAM_OFF_256SBC 8 * 64
#define FREQ_DOMAIN_CORR_STREAM_OFF_512SBC 16 * 64
#define FREQ_DOMAIN_CORR_STREAM_OFF_1024SBC 32 * 64

#if !defined(__ASSEMBLER__)
// ---------------------------------------------------------------------------
//! @brief      This function performs frequency domain correction including:
//!                 - a linear phase ramp (common to all streams)
//!                 - complex gain for amplitude and phase correction (common to all streams)
//!             The function applies in-place a common correction to all streams:
//!                 x(k,m) = x(k,m) * g * exp(-j * 2 * pi * f / 2^32 * (ki + k))
//!             where:
//!                 x(k,m) - is the subcarrier with index "k" and stream "m"
//!                 g      - complex gain ("gain_cpx")
//!                 f      - phase ramp ("phase_ramp")
//!                 k      - sample index (k = 0 ... 63)
//!                 ki     - initial phase ("phase_init")
//!
//! @param[in]  inp_p         Pointer to input/output buffer (16bit complex half-float, vector aligned).
//! @param[in]  gain_cpx_p    Pointer to complex gain (32bit complex single-precision, vector non-aligned).
//! @param[in]  scratch_p     Pointer to scratch buffer (2 DMEM lines, vector aligned).
//! @param[in]  phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement) in NCO format ("f").
//! @param[in]  phase_init    Initial phase (signed 32-bit integer, 1's complement) in NCO format ("ki").
//! @param[in]  num_streams   Number of streams (1 .. 8).
//!
//! @cycle      58 + 4 * num_streams
//!
//! @attention  This function assumes each stream includes: data, pilot and also NULL (DC) subcarriers.
//! @attention  Subsequent streams are assumed allocated in memory at offsets equal to
//!             FREQ_DOMAIN_CORR_STREAM_OFF_64SBC (in half-words). Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void freq_domain_corr_64sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                            int32_t phase_init, uint32_t num_streams);

// ---------------------------------------------------------------------------
//! @brief      This function performs frequency domain correction including:
//!                 - a linear phase ramp (common to all streams)
//!                 - complex gain for amplitude and phase correction (common to all streams)
//!             The function applies in-place a common correction to all streams:
//!                 x(k,m) = x(k,m) * g * exp(-j * 2 * pi * f / 2^32 * (ki + k))
//!             where:
//!                 x(k,m) - is the subcarrier with index "k" and stream "m"
//!                 g      - complex gain ("gain_cpx")
//!                 f      - phase ramp ("phase_ramp")
//!                 k      - sample index (k = 0 ... 127)
//!                 ki     - initial phase ("phase_init")
//!
//! @param[in]  inp_p         Pointer to input/output buffer (16bit complex half-float, vector aligned).
//! @param[in]  gain_cpx_p    Pointer to complex gain (32bit complex single-precision, vector non-aligned).
//! @param[in]  scratch_p     Pointer to scratch buffer (4 DMEM lines, vector aligned).
//! @param[in]  phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement) in NCO format ("f").
//! @param[in]  phase_init    Initial phase (signed 32-bit integer, 1's complement) in NCO format ("ki").
//! @param[in]  num_streams   Number of streams (1 .. 8).
//!
//! @cycle      65 + 8 * num_streas
//!
//! @attention  This function assumes each stream includes: data, pilot and also NULL (DC) subcarriers.
//! @attention  Subsequent streams are assumed allocated in memory at offsets equal to
//!             FREQ_DOMAIN_CORR_STREAM_OFF_128SBC (in half-words). Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void freq_domain_corr_128sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams);

// ---------------------------------------------------------------------------
//! @brief      This function performs frequency domain correction including:
//!                 - a linear phase ramp (common to all streams)
//!                 - complex gain for amplitude and phase correction (common to all streams)
//!             The function applies in-place a common correction to all streams:
//!                 x(k,m) = x(k,m) * g * exp(-j * 2 * pi * f / 2^32 * (ki + k))
//!             where:
//!                 x(k,m) - is the subcarrier with index "k" and stream "m"
//!                 g      - complex gain ("gain_cpx")
//!                 f      - phase ramp ("phase_ramp")
//!                 k      - sample index (k = 0 ... 255)
//!                 ki     - initial phase ("phase_init")
//!
//! @param[in]  inp_p         Pointer to input/output buffer (16bit complex half-float, vector aligned).
//! @param[in]  gain_cpx_p    Pointer to complex gain (32bit complex single-precision, vector non-aligned).
//! @param[in]  scratch_p     Pointer to scratch buffer (8 DMEM lines, vector aligned).
//! @param[in]  phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement) in NCO format ("f").
//! @param[in]  phase_init    Initial phase (signed 32-bit integer, 1's complement) in NCO format ("ki").
//! @param[in]  num_streams   Number of streams (1 .. 8).
//!
//! @cycle      70 + 24 * num_streams
//!
//! @attention  This function assumes each stream includes: data, pilot and also NULL (DC) subcarriers.
//! @attention  Subsequent streams are assumed allocated in memory at offsets equal to
//!             FREQ_DOMAIN_CORR_STREAM_OFF_256SBC (in half-words). Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void freq_domain_corr_256sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams);

// ---------------------------------------------------------------------------
//! @brief      This function performs frequency domain correction including:
//!                 - a linear phase ramp (common to all streams)
//!                 - complex gain for amplitude and phase correction (common to all streams)
//!             The function applies in-place a common correction to all streams:
//!                 x(k,m) = x(k,m) * g * exp(-j * 2 * pi * f / 2^32 * (ki + k))
//!             where:
//!                 x(k,m) - is the subcarrier with index "k" and stream "m"
//!                 g      - complex gain ("gain_cpx")
//!                 f      - phase ramp ("phase_ramp")
//!                 k      - sample index (k = 0 ... 511)
//!                 ki     - initial phase ("phase_init")
//!
//! @param[in]  inp_p         Pointer to input/output buffer (16bit complex half-float, vector aligned).
//! @param[in]  gain_cpx_p    Pointer to complex gain (32bit complex single-precision, vector non-aligned).
//! @param[in]  scratch_p     Pointer to scratch buffer (16 DMEM lines, vector aligned).
//! @param[in]  phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement) in NCO format ("f").
//! @param[in]  phase_init    Initial phase (signed 32-bit integer, 1's complement) in NCO format ("ki").
//! @param[in]  num_streams   Number of streams (1 .. 8).
//!
//! @cycle      86 + 48 * num_streams
//!
//! @attention  This function assumes each stream includes: data, pilot and also NULL (DC) subcarriers.
//! @attention  Subsequent streams are assumed allocated in memory at offsets equal to
//!             FREQ_DOMAIN_CORR_STREAM_OFF_512SBC (in half-words). Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void freq_domain_corr_512sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                             int32_t phase_init, uint32_t num_streams);

// ---------------------------------------------------------------------------
//! @brief      This function performs frequency domain correction including:
//!                 - a linear phase ramp (common to all streams)
//!                 - complex gain for amplitude and phase correction (common to all streams)
//!             The function applies in-place a common correction to all streams:
//!                 x(k,m) = x(k,m) * g * exp(-j * 2 * pi * f / 2^32 * (ki + k))
//!             where:
//!                 x(k,m) - is the subcarrier with index "k" and stream "m"
//!                 g      - complex gain ("gain_cpx")
//!                 f      - phase ramp ("phase_ramp")
//!                 k      - sample index (k = 0 ... 1023)
//!                 ki     - initial phase ("phase_init")
//!
//! @param[in]  inp_p         Pointer to input/output buffer (16bit complex half-float, vector aligned).
//! @param[in]  gain_cpx_p    Pointer to complex gain (32bit complex single-precision, vector non-aligned).
//! @param[in]  scratch_p     Pointer to scratch buffer (32 DMEM lines, vector aligned).
//! @param[in]  phase_ramp    Linear phase ramp (signed 32-bit integer, 1's complement) in NCO format ("f").
//! @param[in]  phase_init    Initial phase (signed 32-bit integer, 1's complement) in NCO format ("ki").
//! @param[in]  num_streams   Number of streams (1 .. 8).
//!
//! @cycle      118 + 96 * num_streams
//!
//! @attention  This function assumes each stream includes: data, pilot and also NULL (DC) subcarriers.
//! @attention  Subsequent streams are assumed allocated in memory at offsets equal to
//!             FREQ_DOMAIN_CORR_STREAM_OFF_1024SBC (in half-words). Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void freq_domain_corr_1024sbc(cfloat16_t *inp_p, cfloat32_t *gain_cpx_p, cfloat16_t *scratch_p, int32_t phase_ramp,
                              int32_t phase_init, uint32_t num_streams);

// ---------------------------------------------------------------------------
//! @brief      This function performs a vector multiplication between a common
//!             vector and multiple vectors. The multiplication is performed in-place.
//!                     vec(k,n) = vec(k,n) * corr(k)
//!                     k = 0 .. 63, n = 1 .. num_vec
//!
//! @param[in]  corr_p        Pointer to input common correction buffer (16bit complex half-float, vector aligned).
//! @param[in]  vec_p         Pointer to input/output vector buffers (16bit complex half-float, vector aligned).
//! @param[in]  num_vec       Number of vectors.
//!
//! @attention Subsequent vectors are assumed allocated with offsets equal to FREQ_DOMAIN_CORR_STREAM_OFF_64SBC (in half-words).
//!            Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void vec_mult_64chp(cfloat16_t *corr_p, cfloat16_t *vec_p, uint32_t num_vec);

// ---------------------------------------------------------------------------
//! @brief      This function performs a vector multiplication between a common
//!             vector and multiple vectors. The multiplication is performed in-place.
//!                     vec(k,n) = vec(k,n) * corr(k)
//!                     k = 0 .. 127, n = 1 .. num_vec
//!
//! @param[in]  corr_p        Pointer to input common correction buffer (16bit complex half-float, vector aligned).
//! @param[in]  vec_p         Pointer to input/output vector buffers (16bit complex half-float, vector aligned).
//! @param[in]  num_vec       Number of vectors.
//!
//! @attention Subsequent vectors are assumed allocated with offsets equal to FREQ_DOMAIN_CORR_STREAM_OFF_128SBC (in half-words).
//!            Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void vec_mult_128chp(cfloat16_t *corr_p, cfloat16_t *vec_p, uint32_t num_vec);

// ---------------------------------------------------------------------------
//! @brief      This function performs a vector multiplication between a common
//!             vector and multiple vectors. The multiplication is performed in-place.
//!                     vec(k,n) = vec(k,n) * corr(k)
//!                     k = 0 .. 255, n = 1 .. num_vec
//!
//! @param[in]  corr_p        Pointer to input common correction buffer (16bit complex half-float, vector aligned).
//! @param[in]  vec_p         Pointer to input/output vector buffers (16bit complex half-float, vector aligned).
//! @param[in]  num_vec       Number of vectors.
//!
//! @attention Subsequent vectors are assumed allocated with offsets equal to FREQ_DOMAIN_CORR_STREAM_OFF_256SBC (in half-words).
//!            Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void vec_mult_256chp(cfloat16_t *corr_p, cfloat16_t *vec_p, uint32_t num_vec);

// ---------------------------------------------------------------------------
//! @brief      This function performs a vector multiplication between a common
//!             vector and multiple vectors. The multiplication is performed in-place.
//!                     vec(k,n) = vec(k,n) * corr(k)
//!                     k = 0 .. 511, n = 1 .. num_vec
//!
//! @param[in]  corr_p        Pointer to input common correction buffer (16bit complex half-float, vector aligned).
//! @param[in]  vec_p         Pointer to input/output vector buffers (16bit complex half-float, vector aligned).
//! @param[in]  num_vec       Number of vectors.
//!
//! @attention Subsequent vectors are assumed allocated with offsets equal to FREQ_DOMAIN_CORR_STREAM_OFF_512SBC (in half-words).
//!            Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void vec_mult_512chp(cfloat16_t *corr_p, cfloat16_t *vec_p, uint32_t num_vec);

// ---------------------------------------------------------------------------
//! @brief      This function performs a vector multiplication between a common
//!             vector and multiple vectors. The multiplication is performed in-place.
//!                     vec(k,n) = vec(k,n) * corr(k)
//!                     k = 0 .. 1023, n = 1 .. num_vec
//!
//! @param[in]  corr_p        Pointer to input common correction buffer (16bit complex half-float, vector aligned).
//! @param[in]  vec_p         Pointer to input/output vector buffers (16bit complex half-float, vector aligned).
//! @param[in]  num_vec       Number of vectors.
//!
//! @attention Subsequent vectors are assumed allocated with offsets equal to FREQ_DOMAIN_CORR_STREAM_OFF_1024SBC (in half-words).
//!            Change the macro for actual allocation.
//! ---------------------------------------------------------------------------
void vec_mult_1024chp(cfloat16_t *corr_p, cfloat16_t *vec_p, uint32_t num_vec);

#endif // !defined( __ASSEMBLER__ )
#endif // __FREQ_DOMAIN_CORR__
