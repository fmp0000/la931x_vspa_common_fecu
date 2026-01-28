// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// ===========================================================================
//! @file            sigcond2.h
//! @brief           Custom signal conditioning functions
//! @ingroup         GROUP_SIGCOND
//!
//! The sigcond.h header defines front end signal conditioning functions
//!
// ===========================================================================

#ifndef __CUSTOMSIGCOND2_H__
#define __CUSTOMSIGCOND2_H__

#include "sigcond.h"

// -----------------------------------------------------------------------------
//!
//!
//! This library contains function prototypes for signal conditioning functions
//!   - Signal conditioning function
//!      - customsigcond2_ddc2x_N2560_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 2560 input samples
//!      - customsigcond2_ddc2x_N640_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond2_ddc4x_N640_5t(): Signal conditioning with 4x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond2_ddc2x_N576_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond2_ddc4x_N576_5t(): Signal conditioning with 4x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond2_ddc8x_N640_5t(): Signal conditioning with 8x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond2_ddc2x_N256_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 256 input samples
//!      - customsigcond2_ddc4x_N256_5t(): Signal conditioning with 4x decimation, 5 I/Q imb taps for 256 input samples
//!      - customsigcond2_ddc8x_N256_5t(): Signal conditioning with 8x decimation, 5 I/Q imb taps for 256 input samples
//!
//! @{
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// variable
// -----------------------------------------------------------------------------

#ifndef __ASSEMBLER__

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 2560 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 762
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 2560 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc2x_N2560_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                          vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                          structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 274
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation->Gain&DCOffset -> Decim2x -> Mixer
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 640 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc2x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 319
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer -> Decim2x
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 640 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc4x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 351
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 640 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc8x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 576 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 250
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation->Gain&DCOffset -> Decim2x -> Mixer
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 576 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N576"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc2x_N576_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 576 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 291
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer -> Decim2x
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 576 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N576"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc4x_N576_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 131
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 288 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N256"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc2x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 149
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer -> Decim2x
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 288 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N256"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc4x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_IQSSFILT_NUMTAPS+1) applied in modulo
//!manner. 								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 160
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					IQ Imbalance compensation -> Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x
//!					Details of input structure are described in "doc/customsigcond2_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 256 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N256"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond2_ddc8x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

#endif //__ASSEMBLER__
#endif // __CUSTOMSIGCOND2_H__

//! @} GROUP_SIGCOND
