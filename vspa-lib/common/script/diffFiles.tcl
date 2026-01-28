# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025 copy  Freescale Semiconductor Inc

# ==============================================================================
#! @file            diffFiles.tcl
#! @brief           CodeWarrior VSPA debugger helper functions.
#! @copyright       &copy; 2016 Freescale Semiconductor, Inc.
# ==============================================================================
set DIFF_FILE_MATCH     0
set DIFF_FILE_MISMATCH  1
set DIFF_FILE_DIRNAME   [file normalize [file dirname [info script]]]

# ------------------------------------------------------------------------------
#! @brief           Function to compare two files for bit-exactness.
#!                  Uses the diff.exe executable for this purpose.
#!
#! @return          0/1 for match/mismatch
# ------------------------------------------------------------------------------
proc diffFiles { FilePath1 FilePath2 } {

    global DIFF_FILE_MATCH
    global DIFF_FILE_MISMATCH
    global DIFF_FILE_DIRNAME
    
    # Compare
    set errCode [catch { exec "${DIFF_FILE_DIRNAME}/diff.exe" -s $FilePath1 $FilePath2 } errMsg ]
    
    if { $errCode == 0 } then {
        if {[string first "identical" $errMsg] == -1} then {
            puts "************************************"
            puts "ERROR: Output data not correct!" 
            puts "************************************"
            return $DIFF_FILE_MISMATCH
        } else {
            puts "************************************"
            puts "OK: Output data correct."
            puts "************************************"
            return $DIFF_FILE_MATCH
        }
    } else {
        puts "ERROR: ${errMsg}!"
        return -1
    }
}









