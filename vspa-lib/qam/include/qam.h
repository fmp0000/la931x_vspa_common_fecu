// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// ===========================================================================
//! @file            qam.h
//! @brief           QAM module interface definitions.
//!
//! The qam.h header defines the QAM module application programming
//! interface.
//!
//! This header declares function prototypes for QAM module
//!
// ===========================================================================

#ifndef __QAM_H__
#define __QAM_H__

// ---------------------------------------------------------------------------
//! @defgroup        GROUP_QAM
//!
//! The QAM module provides the following functions:
//!      - qamMod():
//!      - qamModBpsk():
//!      - qamModQpsk():
//!      - qamMod16():
//!      - qamMod64():
//!      - qamMod256():
//!      - qamMod1024():
//!      - qamDemod():
//!      - qamDemodBpsk():
//!      - qamDemodQpsk():
//!      - qamDemod16():
//!      - qamDemod64():
//!      - qamDemod256():
//!      - qamDemod1024():
//!      - qamLlrPack():
//!      - qamDemod2Ch():
//!		 - qamDemod256Nr:
//!		 - qamDemodQpskNr:
//!
//! @{
// ---------------------------------------------------------------------------

#define QAM_BPSK 1
#define QAM_QPSK 2
#define QAM_16 4
#define QAM_64 6
#define QAM_256 8
#define QAM_1024 10

#define QAM_NORMALIZATION_BPSK 0x3F800000 // 1
#define QAM_NORMALIZATION_QPSK 0x3F3504F3 // 1/sqrt(2)
#define QAM_NORMALIZATION_16 0x3EA1E89B   // 1/sqrt(10)
#define QAM_NORMALIZATION_64 0x3E1E01B2   // 1/sqrt(42)
#define QAM_NORMALIZATION_256 0x3D9D130D  // 1/sqrt(170)
#define QAM_NORMALIZATION_1024 0x3D1CD80C // 1/sqrt(682)

#define SATURATION_SCALING_FACTOR_5G 0x3C000000   // 1/128
#define SATURATION_SCALING_FACTOR_WIFI 0xBD800000 // -1/16

#ifndef __ASSEMBLER__
// ---------------------------------------------------------------------------
//! @brief          wrapping function to invoke qam modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             Number of lines output complex symbols
//! @param[in]  M             Modulation order
//! @return     Void.
//!
//! This function is the wrapper function to jump to one of the corresponding modulation function depending on the modulation order
//! M.
//!
// ---------------------------------------------------------------------------
extern void qamMod(unsigned int *bitIn,          // ptr to the input bit streams
                   vspa_complex_float16 *qamOut, // ptr to the output symbols in complex HFloat
                   unsigned int N,               // number of lines of output complex symbols
                   unsigned int M                // Modulation order
);

// ---------------------------------------------------------------------------
//! @brief           BPSK modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines output complex symbols
//! @return     Void.
//! @cycle      19+2N
//!
//! This function modulates the input bit stream and map it to the BPSK constellation according to the IEEE 802.11-2012 standard. It
//! also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_BPSK.
//!
//! @attention	The output is in complex half floating precision and the imaginary part are all ZEROs.
//! @attention  Minimum output size is one line
// ---------------------------------------------------------------------------
extern void qamModBpsk(unsigned int *bitIn,          // ptr to the input bit streams
                       vspa_complex_float16 *qamOut, // ptr to the output symbols in complex HFloat
                       unsigned int N                // number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           QPSK modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines output complex symbols
//! @return     Void.
//! @cycle      19+2N
//!
//! This function modulates the input bit stream and map it to the QPSK constellation according to the IEEE 802.11-2012 standard. It
//! also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_QPSK.
//!
//! @attention  Minimum output size is one line
// ---------------------------------------------------------------------------
extern void qamModQpsk(unsigned int *bitIn,          // ptr to the input bit streams
                       vspa_complex_float16 *qamOut, //  ptr to the output symbols in complex HFloat
                       unsigned int N                //  number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           16QAM modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines output complex symbols
//! @return     Void.
//! @cycle      17+2N
//!
//! This function modulates the input bit stream and map it to the 16-QAM constellation according to the IEEE 802.11-2012 standard.
//! It also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_16.
//!
//! @attention  Minimum output size is one line
// ---------------------------------------------------------------------------
extern void qamMod16(unsigned int *bitIn,          // ptr to the input bit streams
                     vspa_complex_float16 *qamOut, //  ptr to the output symbols in complex HFloat
                     unsigned int N                //  number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           64QAM modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines of output complex symbols. N must be 1, 2, 3, 4, 8 or 16K where K is a positive
//! integer
//! @return     Void.
//! @cycle      23+N		N=1,2,3 or 4
//!             34			N=8
//!				17+N/16*38  N=16K
//!
//! This function modulates the input bit stream and map it to the 64-QAM constellation according to the IEEE 802.11-2012 standard.
//! It also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_64.
//!
//! @attention  The output size is 1, 2, 3, 4, 8 or 16K lines, where K is a positive integer
// ---------------------------------------------------------------------------
extern void qamMod64(unsigned int *bitIn,          // ptr to the input bit streams
                     vspa_complex_float16 *qamOut, //  ptr to the output symbols in complex HFloat
                     unsigned int N                //  number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           256QAM modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines output complex symbols
//! @return     Void.
//! @cycle      17+2N
//!
//! This function modulates the input bit stream and map it to the 256-QAM constellation according to the IEEE 802.11ac standard. It
//! also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_256.
//!
//! @attention  Minimum output size is one line
// ---------------------------------------------------------------------------
extern void qamMod256(unsigned int *bitIn,          // ptr to the input bit streams
                      vspa_complex_float16 *qamOut, //  ptr to the output symbols in complex HFloat
                      unsigned int N                //  number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           1024QAM modulation function
//!
//! @param[in]	bitIn   	  Input buffer containing bit stream. Must be vector aligned
//! @param[out] qamOut        Output buffer containing modulated symbols in complex half float precision; Must be vector aligned
//! @param[in]  N             number of lines of output complex symbols. N must be 1, 2, 3, 4, 8 or 16K where K is a positive
//! integer
//! @return     Void
//! @cycle      30+N		N=1,2 or 3
//!             35			N=4
//!             39			N=8
//!				17+N/16*44  N=16K
//!
//! This function modulates the input bit stream and map it to the 1024-QAM constellation according to the IEEE 802.11ax standard.
//! It also normalizes the QAM symbol with the scalar # defined as QAM_NORMALIZATION_1024.
//!
//! @attention  The output size must be 1, 2, 3, 4, 8 or 16K lines, where K is a positive integer
// ---------------------------------------------------------------------------
extern void qamMod1024(unsigned int *bitIn,          // ptr to the input bit streams
                       vspa_complex_float16 *qamOut, //  ptr to the output symbols in complex HFloat
                       unsigned int N                //  number of lines of output complex symbols
);

// ---------------------------------------------------------------------------
//! @brief          wrapping function to invoke qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR scalar in linear scale
//! @param[in]  N             Number of lines of input complex symbols
//! @param[in]  M             Modulation order
//! @return     Void.
//!
//! This function is the wrapper function to invoke one of the corresponding demodulation function depending on the modulation order
//! M.
//!
//! @attention A scratch buffer labeled @qamDemodScratch is assumed to be available. This buffer is vector aligned and has a
//!            size of M/2 times the size of input buffer (qamIn). For QPSK (M=2), this buffer is not needed. The minimum size
//!            for this scratch buffer is:
//!			   BPSK: 1 DMEM line
//!            QPSK: not needed
//!            16QAM: 6 DMEM lines
//!            64QAM: 9 DMEM lines
//!            128QAM: 12 DMEM lines
//!
// ---------------------------------------------------------------------------
extern void qamDemod(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                     unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                     float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                     unsigned int N,              // number of lines of input complex symbols
                     unsigned int M               // Modulation order
);

// ---------------------------------------------------------------------------
//! @brief           BPSK demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex BPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      30+5*N/2  (including the cycles for qamLlrPack)
//!
//! This function demodulates the BPSK input bit stream, and output quantized LLRs
//!
//! @attention	The input samples are assumed to be in complex half floating precision and only the real part contains the valid
//! data.
//! @attention  Minimum input size is 2 lines (N>=2)
//! @attention  Input size N must be integer multiply of 2
// ---------------------------------------------------------------------------
extern void qamDemodBpsk(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                         unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                         float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                         unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           QPSK demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      17+2*N (including the cycles for qamLlrPack)
//!
//! This function demodulates the QPSK input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 1 lines
// ---------------------------------------------------------------------------
extern void qamDemodQpsk(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                         unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                         float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                         unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           16-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      including the cycles for qamLlrPack
//!				25+7*N   N>2
//!             46       N=2
//!
//! This function demodulates the 16-qam input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 2 lines
// ---------------------------------------------------------------------------
extern void qamDemod16(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                       unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                       float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                       unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           64-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      including the cycles for qamLlrPack
//!				35+11*N;  N>2
//!             68;       N=2
//!
//! This function demodulates the 64-qam input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 2 lines
// ---------------------------------------------------------------------------
extern void qamDemod64(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                       unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                       float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                       unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           256-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      including the cycles for qamLlrPack
//!				44+15*N   N>2
//!             89        N=2
//!
//! This function demodulates the 256-qam input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 2 lines
// ---------------------------------------------------------------------------
extern void qamDemod256(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                        unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                        float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                        unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           1024-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle      including the cycles for qamLlrPack
//!				52+19*N
//!
//! This function demodulates the 1024-qam input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 2 lines
// ---------------------------------------------------------------------------
extern void qamDemod1024(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                         unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                         float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                         unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           snr scaling and llr packing function
//!
//! @param[in]	llrIn   	  Input buffer containing real input LLRs in HFloat (LLR values before SNR scaling). Must be vector
//! aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input LLRs
//! @return     Void.
//! @cycle      14+2*N
//!
//! This function scales the input LLRs by the SNR value, and output quantized LLRs
//!
// ---------------------------------------------------------------------------
extern void qamLlrPack(__fp16 *llrIn,        // ptr to real input LLRs in HFloat (LLR values before SNR scaling)
                       unsigned int *llrOut, // ptr to output LLRs in 8-bit format
                       float SNR,            // SNR parameter in linear scale (used to scale the LLRs)
                       unsigned int N        // number of lines of input LLRs
);

// ---------------------------------------------------------------------------
//! @brief          wrapping function to invoke qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR scalar in linear scale
//! @param[in]  N             Number of lines of input complex symbols for each channel
//! @param[in]  M             Modulation order
//! @return     Void.
//!
//! This function is the wrapper function to invoke one of the corresponding demodulation function depending on the modulation order
//! M.
//!
//! @attention A scratch buffer labeled @qamDemodScratch is assumed to be available. This buffer is vector aligned and has a
//!            size of M/2 times the size of input buffer (qamIn). For QPSK (M=2), this buffer is not needed. The minimum size
//!            for this scratch buffer is:
//!			   BPSK: 1 DMEM line
//!            QPSK: not needed
//!            16QAM: 6 DMEM lines
//!            64QAM: 9 DMEM lines
//!            128QAM: 12 DMEM lines
//! @attention The input data for 1st channel is stored at @qamIn and input data for 2nd channel is stored at @qamIn + OFFSET1
//!            The output llrs for 1st channel is stored at @llrOut and output data for 2nd channel is stored at @llrOut + OFFSET2
//!            The units for OFFSET1 and OFFSET2 are 16-bit half-words, and they are # defined inside the assembly function
//!
// ---------------------------------------------------------------------------
extern void qamDemod2Ch(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                        unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                        float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                        unsigned int N,              // number of lines of input complex symbols for each channel
                        unsigned int M               // Modulation order
);

// ---------------------------------------------------------------------------
//! @brief           256-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex 256QAM input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle		91+2x(N-1)+3x3x(n-5)= 44+11*N
//!
//! This function demodulates the 256-qam input bit stream, and output quantized LLRs
//!
//! @attention  Minimum input size is 5 lines
//! @attention A scratch buffer labeled @qamDemodScratch is assumed to be available. This buffer is vector aligned and has
//!            a size of N dmem lines
// ---------------------------------------------------------------------------
extern void qamDemod256V2(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                          unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                          float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                          unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           256-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex 256QAM input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of N dmem lines.  Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle		91+2x(N-1)+3x3x(n-5)= 44+11*N
//!
//! This function demodulates the 256-qam input bit stream, and outputs quantized LLRs
//!
//! @attention  The difference between this function and the previous version qamDemod256V2() is the SIGN CHANGE of the outputs
//! @attention  Minimum input size is 5 lines
// ---------------------------------------------------------------------------
extern void qamDemod256Nr(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                          unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                          vspa_complex_float16 *scratch, // ptr to the scratch buffer
                          float SNR,                     // SNR parameter in linear scale (used to scale the LLRs)
                          unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief      QPSK demodulation function for 5gNR standard
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]  SNR           SNR parameter in linear scale
//! @param[in]  N             number of lines of input complex symbols
//! @return     Void.
//! @cycle		14+2*N
//!
//! This function demodulates the QPSK input bit stream, and outputs quantized LLRs
//!
//! @attention  Minimum input size is 1 lines
//! @attention  Unlike other qamDemod functions, no scratch buffer is needed for this function
// ---------------------------------------------------------------------------
extern void qamDemodQpskNr(vspa_complex_float16 *qamIn, // ptr to complex input symbols in complex HFloat
                           unsigned int *llrOut,        // ptr to LLRs in 8 bit format
                           float SNR,                   // SNR parameter in linear scale (used to scale the LLRs)
                           unsigned int N               // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           256-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex 256QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 1.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols. N must be an even integer.
//! @return     Void.
//! @cycle		70+15*N
//!
//! This function demodulates the 256-qam input bit stream, and outputs quantized LLRs.
//!
//! @attention  The difference between this function and the previous version qamDemod256V2() is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemod256V3(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                          __fp16 *SNR,                   // ptr to snr vector in real HFloat
                          unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                          vspa_complex_float16 *scratch, // ptr to the scratch buffer
                          unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           64-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex 256QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 1.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @return     Void.
//! @cycle		58+11*N
//!
//! This function demodulates the 64-qam input bit stream, and outputs quantized LLRs.
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemod64V3(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                         __fp16 *SNR,                   // ptr to snr vector in real HFloat
                         unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                         vspa_complex_float16 *scratch, // ptr to the scratch buffer
                         unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           16-qam demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex 16QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 1.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @return     Void.
//! @cycle		46+7*N
//!
//! This function demodulates the 16-qam input bit stream, and outputs quantized LLRs.
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemod16V3(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                         __fp16 *SNR,                   // ptr to snr vector in real HFloat
                         unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                         vspa_complex_float16 *scratch, // ptr to the scratch buffer
                         unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           QPSK demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex QPSK input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 0.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @return     Void.
//! @cycle		28+3.5*N
//!
//! This function demodulates the QPSK input bit stream, and outputs quantized LLRs.
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemodQpskV3(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                           __fp16 *SNR,                   // ptr to snr vector in real HFloat
                           unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                           vspa_complex_float16 *scratch, // ptr to the scratch buffer
                           unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           BPSK demodulation function
//!
//! @param[in]	qamIn   	  Input buffer containing complex BPSK input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 0.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @return     Void.
//! @cycle		26+3*N
//!
//! This function demodulates the BPSK input bit stream, and outputs quantized LLRs.
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemodBpskV3(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                           __fp16 *SNR,                   // ptr to snr vector in real HFloat
                           unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                           vspa_complex_float16 *scratch, // ptr to the scratch buffer
                           unsigned int N                 // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief      QAM demodulation function wrapper function for 5G/LTE std
//!
//! @param[in]	qamIn   	  Input buffer containing complex 16QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @param[in]  M             modulation order, integer scalar;
//!							  M=2  QPSK
//!							  M=4  16QAM
//!							  M=6  64QAM
//!							  M=8  256QAM
//! @return     Void.
//! @cycle
//!
//! This function calls various QAM demod functions, depending on the value of modulation order M
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
//! @attention  For QPSK demod, the scratch buffer is NOT needed
// ---------------------------------------------------------------------------
extern void qamDemodV3_5g(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                          __fp16 *SNR,                   // ptr to snr vector in real HFloat
                          unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                          vspa_complex_float16 *scratch, // ptr to the scratch buffer
                          unsigned int N,                // number of lines of input complex symbols
                          unsigned int M                 // modulation order, integer scalar;
);

// ---------------------------------------------------------------------------
//! @brief      QAM demodulation function wrapper function for Wifi std
//!
//! @param[in]	qamIn   	  Input buffer containing complex 16QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in 8 bit format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @param[in]  M             modulation order, integer scalar;
//!							  M=2  QPSK
//!							  M=4  16QAM
//!							  M=6  64QAM
//!							  M=8  256QAM
//! @return     Void.
//! @cycle
//!
//! This function calls various QAM demod functions, depending on the value of modulation order M
//!
//! @attention  The difference between this function and the previous version is this function
//!             implements a vector SNR scaling.
//! @attention  N must be and even number. Min value = 2.
//! @attention  For QPSK demod, the scratch buffer is NOT needed
// ---------------------------------------------------------------------------
extern void qamDemodV3_Wifi(vspa_complex_float16 *qamIn,   // ptr to complex input symbols in complex HFloat
                            __fp16 *SNR,                   // ptr to snr vector in real HFloat
                            unsigned int *llrOut,          // ptr to LLRs in 8 bit format
                            vspa_complex_float16 *scratch, // ptr to the scratch buffer
                            unsigned int N,                // number of lines of input complex symbols
                            unsigned int M                 // modulation order, integer scalar;
);

// ---------------------------------------------------------------------------
//! @brief           QPSK demodulation function V4
//!
//! @param[in]	qamIn   	  Input buffer containing complex 16QAM input symbols in complex HFloat. Must be vector aligned
//! @param[in]  SNR           SNR buffer containing SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in HFixed format. Must be vector aligned
//! @param[in]	scratch   	  scratch buffer of 0.5*N dmem lines.  Must be vector aligned
//! @param[in]  N             number of lines of input complex symbols.
//!                           N= ceil(Nsym/64)*2, (Nsym= # of input complex symbols) i.e. N must be an even integer
//! @return     Void.
//! @cycle		28+3.5*N
//!
//! This function demodulates the QPSK input bit stream, and outputs quantized LLRs in Hfixed format
//!
//! @attention  The difference between this function and the previous version V# is this function
//!             outputs the LLRs in 16-bit HFixed format instead of 8-bit format
//! @attention  N must be and even number. Min value = 2.
// ---------------------------------------------------------------------------
extern void qamDemodQpskV4(vspa_complex_float16 const *qamIn, // ptr to complex input symbols in complex HFloat
                           __fp16 const *SNR,                 // ptr to snr vector in real HFloat
                           vspa_complex_fixed16 *llrOut,      // ptr to LLRs in Hfixed format
                           vspa_complex_float16 *scratch,     // ptr to the scratch buffer
                           unsigned int N                     // number of lines of input complex symbols
);

// ---------------------------------------------------------------------------
//! @brief           demodulation function V5
//!
//! @param[in]	qamIn   	  Input buffer containing 8 lines (256 sampless) of complex QAM input symbols in complex HFloat.
//!                           Must be vector aligned
//! @param[in]  SNR           SNR buffer containing 4 lines SNR vector in real HFloat. Must be vector aligned.
//! @param[out] llrOut        Output buffer containing LLRs in HFixed format. Must be vector aligned. Output buffer size is
//!                           20 lines for 1024 QAM
//!                           16 lines for 256 QAM
//!                           12 lines for 64 QAM
//!                           8  lines for 16 QAM
//!                           4  lines for QPSK
//! @param[in]	scratch   	  scratch buffer.  Must be vector aligned. The size of scratch buffer needed is
//!                           40 lines for 1024 QAM
//!                           32 lines for 256 QAM
//!                           24 lines for 64 QAM
//!                           16 lines for 16 QAM
//!                           0  lines for QPSK (scratch buffer not needed)
//! @param[in]  M             Modulation order.
//!						      M=10  1024 QAM
//!						      M=8   256  QAM
//!						      M=6   64   QAM
//!						      M=4   16   QAM
//!						      M=2   QPSK
//!
//! @return     Void.
//! @cycle		1024-QAM: 127
//!          	256-QAM:  103
//!          	64-QAM:   87
//!          	16-QAM:   67
//!          	QPSK:     35
//!
//!
//! This function demodulates the 8 lines of input QAM symbols, and outputs quantized LLRs in Hfixed format
//!
//! @attention  To take advantage of parallel instruction of st&ld, the caller to this function should  place
//!             the input and output buffer in different memeory (e.g. one in VCPU DMEM and the other in IPPU DMEM).
//!             If this is not the case, the cycle count will be more than the above.
//! @attention  This function also re-orders the llrs with the st.uline.llr8 instruction
//! @attention  This function must be run under VSPA3 environment
// ---------------------------------------------------------------------------
extern void qamDemodV5(vspa_complex_float16 const *qamIn, // ptr to complex input symbols in complex HFloat
                       __fp16 const *SNR,                 // ptr to snr vector in real HFloat
                       unsigned int *llrOut,              // ptr to LLRs in 8 bit format
                       vspa_complex_float16 *scratch,     // ptr to the scratch buffer
                       unsigned int M                     // modulation order, integer scalar;
);

#endif //__ASSEMBLER__

#endif // __QAM_H__

//! @} GROUP_QAM
