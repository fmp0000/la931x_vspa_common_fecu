# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025 copy  Freescale Semiconductor Inc

# ==============================================================================
#! @file            passFail.tcl
#! @brief           CodeWarrior VSPA debugger helper functions.
#! @copyright       &copy; 2016 Freescale Semiconductor, Inc.
# ==============================================================================
# ------------------------------------------------------------------------------
#! @brief           Simple function to summarize the results of a test.
#! @return          void.
# ------------------------------------------------------------------------------
proc passFail { err_count } {

    if {$err_count == 0} {
        puts "*************************************************************************" 
        puts "   PPPPP      AA        SSSS    SSSS " 
        puts "   PP  PP    AAAA      SS  SS  SS  SS" 
        puts "   PPPPP    AA  AA      SS      SS   " 
        puts "   PP      AAAAAAAA       SS      SS " 
        puts "   PP     AA      AA   SS  SS  SS  SS" 
        puts "   PP    AA        AA   SSSS    SSSS " 
        puts "*************************************************************************" 
        puts {   Test finished successfully }
    } else {
        puts "*************************************************************************" 
        puts "   FFFFFF     AA       II   LL     "
        puts "   FF        AAAA      II   LL     "
        puts "   FFFFF    AA  AA     II   LL     "
        puts "   FF      AAAAAAAA    II   LL     "
        puts "   FF     AA      AA   II   LL     "
        puts "   FF    AA        AA  II   LLLLLL "
        puts "*************************************************************************" 
        puts "   Test finished with $err_count errors "
    }
    return 1
}









