// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors All rights reserved

// ===========================================================================
//! @file           bitRev.h
//! @brief          bit-reversal interface definitions.
//! @author         NXP Semiconductors
// ===========================================================================

#ifndef __BITREV_H__
#define __BITREV_H__

// ---------------------------------------------------------------------------
//! @defgroup        GROUP_BITREV bit-reversal Library
//!
//! The bit-reversal Library provides the following functions:
//!    - bitRev():  performs shifting and bit-reversal on a input of various length
//!    - bitRev64()  : performs shifting and bit-reversal on a 64 sub-carriers input
//!    - bitRev256() : performs shifting and bit-reversal on a 256 sub-carriers input
//!    - bitRev256sEbyE() : performs shifting and bit-reversal on a 256 sub-carriers input
//!                         (outputs element by element)
//!    - bitRev256sEbyEippu() : performs shifting and bit-reversal on a 256 sub-carriers input,
//!                             output buffer in ippu dmem(outputs element by element)
//!    - bitRev1024sEbyE() : performs shifting and bit-reversal on a 1024 sub-carriers input
//!                         (outputs element by element)
//!
//! @{
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 64 sub-carriers input
//!
//! @return       Void.
//! @cycle        fft64:  104
//!               fft128: 173
//!               fft256: 306
//!               fft1204:1119
//!
//! @see          bitRevInvoke()
// ---------------------------------------------------------------------------
extern void bitRev(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev().
//!
//! @param[out]  pOut      pointer to output(linear ordered sub-carriers) buffer
//!						   in IPPU DMEM.(32 bit aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//! @param[in]   mask	   pointer to a mask of integer value, must be one of the
//!                        following value:
//!                        0b0001   64-point fft
//!                        0b0010   128-point fft
//!                        0b0100   256-point fft
//!                        0b1000   1024-point fft
//!                        NOTE: THIS MASK IS A 32-bit WORD, WHICH MUST BE STORED
//!                        AT THE BEGINING OF A DMEM LINE.
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev()
//!
//! This function invokes the IPPU to execute the procedure bitRev().
//!
// ---------------------------------------------------------------------------
extern bool bitRevInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn, unsigned int *mask);

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a sub-carriers input
//!
//! @return       Void.
//! @cycle        91.
//!
//! @see          bitRev64Invoke()
// ---------------------------------------------------------------------------
extern void bitRev64(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev64().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!						   in VCPU.(dmem aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (32 bit aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev64()
//!
//! This function invokes the IPPU to execute the procedure bitRev64().
//!
// ---------------------------------------------------------------------------
extern bool bitRev64Invoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);
// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 64 sub-carriers input
//!
//! @return       Void.
//! @cycle
//!
//! @see          bitRev128Invoke()
// ---------------------------------------------------------------------------
extern void bitRev128(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev128().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!						   in VCPU.(dmem aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (32 bit aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev128()
//!
//! This function invokes the IPPU to execute the procedure bitRev64().
//!
// ---------------------------------------------------------------------------
extern bool bitRev128Invoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 256 sub-carriers input
//!
//! @return       Void.
//! @cycle        308.
//!
//! @see          bitRev256Invoke()
// ---------------------------------------------------------------------------
extern void bitRev256(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev256().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in VCPU.(dmem aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (32 bit aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev256()
//!
//! This function invokes the IPPU to execute the procedure bitRev256().
//!
// ---------------------------------------------------------------------------
extern bool bitRev256Invoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 256 sub-carriers input
//!
//! @return       Void.
//! @cycle        315.
//!
//! @see          bitRev256sEbyEInvoke()
// ---------------------------------------------------------------------------
extern void bitRev256sEbyE(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev256sEbyE().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in VCPU.(32-bit aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev256sEbyE()
//!
//! This function invokes the IPPU to execute the procedure bitRev256sEbyE().
//!
// ---------------------------------------------------------------------------
extern bool bitRev256sEbyEInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 1024 sub-carriers input
//!
//! @return       Void.
//! @cycle        1108.
//!
//! @see          bitRev1024sEbyEInvoke()
// ---------------------------------------------------------------------------
extern void bitRev1024sEbyE(void);

// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev1024sEbyE().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in VCPU.(32-bit aligned)
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev1024sEbyE()
//!
//! This function invokes the IPPU to execute the procedure bitRev1024sEbyE().
//!
// ---------------------------------------------------------------------------
extern bool bitRev1024sEbyEInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);

// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 64 sub-carriers input,
//!               the ouput buffer is in IPPU dmem.
//!
//! @return       Void.
//! @cycle
//!
//! @see          bitRev64sEbyEippuInvoke()
// ---------------------------------------------------------------------------
extern void bitRev64sEbyEippu(void);
// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev64sEbyEippu().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in IPPU.(32-bit aligned)
//!                        offset from base of IPPU dmem.
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev64sEbyEippu()
//!
//! This function invokes the IPPU to execute the procedure bitRev64sEbyEippu().
//!
// ---------------------------------------------------------------------------
extern bool bitRev64sEbyEippuInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);
// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 128 sub-carriers input,
//!               the ouput buffer is in IPPU dmem.
//!
//! @return       Void.
//! @cycle
//!
//! @see          bitRev128sEbyEippuInvoke()
// ---------------------------------------------------------------------------
extern void bitRev128sEbyEippu(void);
// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev128sEbyEippu().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in IPPU.(32-bit aligned)
//!                        offset from base of IPPU dmem.
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev128sEbyEippu()
//!
//! This function invokes the IPPU to execute the procedure bitRev128sEbyEippu().
//!
// ---------------------------------------------------------------------------
extern bool bitRev128sEbyEippuInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);
// ---------------------------------------------------------------------------
//! @brief        Performs shifting and bit-reversal on a 256 sub-carriers input,
//!               the ouput buffer is in IPPU dmem.
//!
//! @return       Void.
//! @cycle        315.
//!
//! @see          bitRev256sEbyEippuInvoke()
// ---------------------------------------------------------------------------
extern void bitRev256sEbyEippu(void);
// ---------------------------------------------------------------------------
//! @brief        VCPU proxy for bitRev256sEbyEippu().
//!
//! @param[in]   pOut      pointer to output(linear ordered sub-carriers) buffer
//!                        in IPPU.(32-bit aligned)
//!                        offset from base of IPPU dmem.
//! @param[in]   pData     pointer to the input buffer in VCPU dmem containing
//!                        sub-carriers in bit-reversed order. (dmem aligned)
//!
//! @retval       true if the IPPU procedure is started.
//! @retval       false if the IPPU procedure could not be started.
//!
//! @see          bitRev256sEbyEippu()
//!
//! This function invokes the IPPU to execute the procedure bitRev256sEbyEippu().
//!
// ---------------------------------------------------------------------------
extern bool bitRev256sEbyEippuInvoke(vspa_complex_float16 *pOut, vspa_complex_float16 const *pIn);

#endif // __BITREV_H__

//! @} GROUP_BITREV
