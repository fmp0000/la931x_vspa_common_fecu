// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// ===========================================================================
//! @file            sigcond.h
//! @brief           Custom signal conditioning functions
//! @ingroup         GROUP_SIGCOND
//!
//! The sigcond.h header defines front end signal conditioning functions
//!
// ===========================================================================

#ifndef __CUSTOMSIGCOND_H__
#define __CUSTOMSIGCOND_H__

// -----------------------------------------------------------------------------
//! @defgroup		GROUP_SIGCOND Signal conditioning functions Library
//! @brief          Signal conditioning functions library
//!
//! This library contains function prototypes for signal conditioning functions
//!   - Signal conditioning function
//!      - customsigcond_ddc1x_N2560_4t(): Signal conditioning with 1x decimation, 4 I/Q imb taps for 2560 input samples
//!      - customsigcond_ddc1x_N2560_5t(): Signal conditioning with 1x decimation, 5 I/Q imb taps for 2560 input samples
//!      - customsigcond_ddc2x_N2560_4t(): Signal conditioning with 2x decimation, 4 I/Q imb taps for 2560 input samples
//!      - customsigcond_ddc2x_N2560_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 2560 input samples
//!      - customsigcond_ddc1x_N1152_4t(): Signal conditioning with 1x decimation, 4 I/Q imb taps for 1152 input samples
//!      - customsigcond_ddc1x_N1152_5t(): Signal conditioning with 1x decimation, 5 I/Q imb taps for 1152 input samples
//!      - customsigcond_ddc2x_N640_4t(): Signal conditioning with 2x decimation, 4 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc2x_N640_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc4x_N640_4t(): Signal conditioning with 4x decimation, 4 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc4x_N640_5t(): Signal conditioning with 4x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc8x_N640_4t(): Signal conditioning with 8x decimation, 4 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc8x_N640_5t(): Signal conditioning with 8x decimation, 5 I/Q imb taps for 640 input samples
//!      - customsigcond_ddc2x_N256_4t(): Signal conditioning with 2x decimation, 4 I/Q imb taps for 256 input samples
//!      - customsigcond_ddc2x_N256_5t(): Signal conditioning with 2x decimation, 5 I/Q imb taps for 256 input samples
//!      - customsigcond_ddc4x_N256_4t(): Signal conditioning with 4x decimation, 4 I/Q imb taps for 256 input samples
//!      - customsigcond_ddc4x_N256_5t(): Signal conditioning with 4x decimation, 5 I/Q imb taps for 256 input samples
//!      - customsigcond_ddc8x_N256_4t(): Signal conditioning with 8x decimation, 4 I/Q imb taps for 256 input samples
//!      - customsigcond_ddc8x_N256_5t(): Signal conditioning with 8x decimation, 5 I/Q imb taps for 256 input samples
//!
//! @{
// -----------------------------------------------------------------------------

#define CUSTOMSIGCOND_IQSSFILT_NUMTAPS 5 // number of taps for IQ SS filter

#define CUSTOMSIGCOND_FIRSTDDCFILTLEN 6              // length of first DDC filter
#define CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560 5120 // size of input circular buffer for N=2560 (in units of 32-bit words)
#define CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N1152 2304 // size of input circular buffer for N=1152 (in units of 32-bit words)
#define CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640 1280  // size of input circular buffer for N=640 (in units of 32-bit words)
#define CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N576 1152  // size of input circular buffer for N=576 (in units of 32-bit words)
#define CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N256 512   // size of input circular buffer for N=256 (in units of 32-bit words)

// -----------------------------------------------------------------------------
// variable
// -----------------------------------------------------------------------------

#ifndef __ASSEMBLER__

// Signal Conditioning configuration struct
typedef struct {
    vspa_complex_fixed16 filtState[96];
    vspa_complex_fixed16 *inCircBuffBase;
    vspa_complex_float32 rxGain;
    vspa_complex_float32 rxDCOffset;
    unsigned int mxrFreq;
    unsigned int mxrPhase;
    float IQImb_ftaps[12];
    unsigned int IQImp_delay;
} structSigCondParams;

// label defining storage for 3 sets of real taps for 3 stages of DDC chain
extern vspa_pair_fixed16 customsigcond_FilterTaps[13];

// label defining scratch memory
extern vspa_complex_fixed16 customsigcond_ScratchMem[2592] __attribute__((aligned(64)));

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 1x decimation for N = 2560 input samples, and, with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 594
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 2560 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc1x_N2560_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 1x decimation for N = 2560 input samples, and, with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 673
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 2560 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc1x_N2560_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 2560 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 724
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 2592 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc2x_N2560_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 2560 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 762
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 2592 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N2560"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc2x_N2560_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 1x decimation for N = 1152 input samples, and, with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 286
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 1152 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N1152"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc1x_N1152_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 1x decimation for N = 1152 input samples, and, with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 321
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 1152 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N1152"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc1x_N1152_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                         vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                         structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 640 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 213
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc2x_N640_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 221
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc2x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 640 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 230
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc4x_N640_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 235
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc4x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 640 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 248
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc8x_N640_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 640 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 250
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
//!
//! @attention		This function uses scratch memory of size 672 (32-bit) words referred to by the symbol
//! "customsigcond_ScratchMem".
//!					The caller needs to allocate this scratch memory.
//! @attention		Size of input circular buffer is defined by the macro "CUSTOMSIGCOND_INPUTCIRCBUFFERSIZE_N640"
//! @attention      Input circular buffer base address for each channel is defined by field structSigCondParams::inCircBuffBase and
//! must
//!					be set by caller
//! @attention      DDC stages filter taps buffer is defined by symbol customsigcond_FilterTaps and must be allocated by caller
//! @attention      Persistent buffer for each channel structSigCondParams::filtState must be cleared on initialization/reset
// ---------------------------------------------------------------------------
extern void customsigcond_ddc8x_N640_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 256 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 111
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc2x_N256_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 2x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 115
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc2x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 256 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 116
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc4x_N256_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 4x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 118
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc4x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 256 input samples, and,  with 4 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 127
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc8x_N256_4t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

// ---------------------------------------------------------------------------
//! @brief          Signal conditioning chain with 8x decimation for N = 256 input samples, and,  with 5 taps for I/Q imbalance
//!					fractional delay compensation filter
//!
//! @param[in]       pIn   		Starting pointer to input vector. This is the first "new" sample. The first stage begins
//! processing
//!								from (pIn-CUSTOMSIGCOND_FIRSTDDCFILTLEN+1) applied in modulo manner.
//!								Half-fixed complex. Input buffer can be circular.
//! @param[out]      pOut   	Pointer to output buffer. Half-fixed complex. Must be DMEM line aligned.
//! @param[out]      pConfig  	Pointer to configuration structure. Must be DMEM aligned.
//! @return          Void.
//! @cycle         	 128
//! @stack         	 0
//!
//! This is a signal conditioning chain implementing the following
//!					Gain&DCOffset -> Decim2x -> Mixer -> Decim2x -> Decim2x -> IQ Imbalance compensation
//!					Details of input structure are described in "doc/customsigcond_function_description.doc"
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
extern void customsigcond_ddc8x_N256_5t(vspa_complex_fixed16 const *pIn, // Input data pointer in half-fixed precision
                                        vspa_complex_fixed16 *pOut,      // Output data pointer in half-fixed precision
                                        structSigCondParams *pConfig     // Structure configuring parameters for the channel
);

#endif //__ASSEMBLER__
#endif // __CUSTOMSIGCOND_H__

//! @} GROUP_SIGCOND
