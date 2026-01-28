// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2017 - 2025   NXP Semiconductors

// ===========================================================================
//! @file            mixer_update.h
//! @brief           Mixer update functions
//! @ingroup         GROUP_MIXER_UPD
//!
//! The mixer_update.h header defines mixer update procedures
//!
// ===========================================================================

#ifndef __MIXER_UPDATE_H__
#define __MIXER_UPDATE_H__

#include <stddef.h>
#include "sigcond.h"

// -----------------------------------------------------------------------------
//! @defgroup		GROUP_MIXER_UPD Miscellaneous mixer functions Library
//! @brief          Miscellaneous mixer functions Library
//!
//! This library contains function prototypes for cyclic shifts
//!   - Frequency and Phase updater
//!      - freq_phase_update(): Frequency and phase update based on delta change in frequency
//!
//! @{
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// variable
// -----------------------------------------------------------------------------

#ifndef __ASSEMBLER__

// ---------------------------------------------------------------------------
//! @brief           Frequency Phase update function compatible with functions of type "customsigcond_*"
//!
//! @param[in/out]   pCfg   		Pointer to configuration/update struct of type structSigCondParams (defined in sigcond.h);
//!									Details of the fields (relevant to this function) are as
//!below 										mxrFreq: Current mixer frequency; the function overwrites this with the updated frequency value 										mxrPhase: Current mixer
//!phase; the function overwrites this with the updated phase value 										rxGain: Current complex gain applied in the signal conditioning
//!function. 												The function overwrites this with an updated gain value. 										rxDCOffset: Current complex DC offset applied in the signal
//!conditioning function. 												The function overwrites this with an updated DC offset value.
//! @param[in]   	delta_mxrfreq: Delta mixer frequency; this is the change to be applied to the current frequency.
//! @return          Void.
//! @cycle         	 34
//! @stack         	 0
//!
//! This function updates the mixer frequency and phase based on the delta frequency change. It also updates the current complex
//! gain and DC offset values used in the signal conditioning function in order to preserve phase continuity when the frequency
//! update is applied. The frequency, phase, gain and DC offset input parameters to the signal conditioning function should be
//! updated based on the output of this function.
//!
// ---------------------------------------------------------------------------
extern void freq_phase_update(structSigCondParams *pCfg, // pointer to update struct
                              int delta_mxrfreq          // delta frequency
);

// ---------------------------------------------------------------------------
//! @brief           Frequency Phase update function compatible with functions of type "customsigcond2_*"
//!
//! @param[in/out]   pCfg   		Pointer to configuration/update struct of type structSigCondParams (defined in sigcond.h);
//!									Details of the fields (relevant to this function) are as
//!below 										filtState: Overwrites the first 32 samples pertinent to saved state of 1st decimation filter (updated for new gain)
//!										mxrFreq: Current mixer frequency; the function overwrites this with the updated
//!frequency value 										mxrPhase: Current mixer phase; the function overwrites this with the updated phase value 										rxGain: Current complex
//!gain applied in the signal conditioning function. 												The function overwrites this with an updated gain value. 										rxDCOffset: Current
//!complex DC offset applied in the signal conditioning function. 												The function overwrites this with an updated DC offset value.
//! @param[in]   	delta_mxrfreq: Delta mixer frequency; this is the change to be applied to the current frequency.
//! @return          Void.
//! @cycle         	 35
//! @stack         	 0
//!
//! This function updates the mixer frequency and phase based on the delta frequency change. It also updates the current complex
//! gain and DC offset values used in the signal conditioning function in order to preserve phase continuity when the frequency
//! update is applied. The frequency, phase, gain and DC offset input parameters to the signal conditioning function should be
//! updated based on the output of this function. Additionally, it applies updated gain to the saved state of the 1st decimation
//! filter to ensure
//!	continuity.
//!
// ---------------------------------------------------------------------------
extern void freq_phase_update2(structSigCondParams *pCfg, // pointer to update struct
                               int delta_mxrfreq          // delta frequency
);

//! @} GROUP_MIXER_UPD

#endif //__ASSEMBLER__
#endif // __MIXER_UPDATE_H__
