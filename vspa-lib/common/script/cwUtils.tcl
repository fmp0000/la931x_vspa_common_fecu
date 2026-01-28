# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025 copy  Freescale Semiconductor Inc

# ==============================================================================
#! @file            cwUtils.tcl
#! @brief           CodeWarrior VSPA debugger helper functions.
#! @copyright       &copy; 2016 Freescale Semiconductor, Inc.
# ==============================================================================

# CodeWarrior path (the platform running this TCL script)
set CW_PATH [file normalize $env(VSPA_TOOLS_HOME)/../] 

# Print path   
puts "CodeWarrior path set automatically: $CW_PATH"

# ------------------------------------------------------------------------------
#! @brief           Function to build a CodeWarrior project.
#!
#! Builds a CodeWarrior project by issuing the ecd.exe command.
#!
#! @param[in]       projPath   Project absolute path.
#! @param[in]       projConf   Project configuration name.
#!
#! @return          Messaje for success/error.
# ------------------------------------------------------------------------------
proc cwBuild { projPath projConf } {

    global CW_PATH
    
    # Issue command
    set errCode [catch { exec "${CW_PATH}/eclipse/ecd.exe" -build -cleanAll -project $projPath -config $projConf } errMsg ]
    
    # Output
    if { $errCode != 0 } {
        error "CodeWarrior build error" $errMsg $errCode
    }
    
    return $errMsg
}

# ------------------------------------------------------------------------------
#! @brief           Function to set a CodeWarrior project macro definition.
#!
#! Sets a CodeWarrior project macro name by issuing the ecd.exe command.
#!
#! @param[in]       projPath   Project absolute path.
#! @param[in]       projConf   Project configuration name.
#! @param[in]       macro      Macro definition.
#! @param[in]       option     Macro option:  set | insert | prepend | append
#!
#! @return          Messaje for success/error.
#!
#! Examples for macro name: "ENABLE_SOME_FEATURE" or "FEATURE_NAME=VALUE" 
#!                        
#! Macro options:                             
#!      set     - replace all the previous macros with a new one
#!      insert  - update existing macro
#!      prepend - prepend a macro to the existing ones
#!      append  - append a macro to the existing ones
#! 
# ------------------------------------------------------------------------------
proc cwChangeMacro { projPath projConf macro option} {

    global CW_PATH

    # Validate option
    set OPTION_LIST {set prepend append insert}
    if {[lsearch $OPTION_LIST $option] < 0} {
        error "Option invalid!"
    }
    
    # Set option id and option value
    set option_id      "fsvspacc.preprocessor.definedMacros"
    set option_value   $macro
    
    # Issue command
    set errCode [catch { exec "${CW_PATH}/eclipse/ecd.exe" -setOptions -project $projPath -config $projConf -$option $option_id $option_value } errMsg ]
    
    # Verify if message contains 'Error' because errCode is not always relevant
    if { [string match *Error* $errMsg] == 1 } {
        set errCode 1 
    }
    
    # Output
    if { $errCode != 0 } {
        error "CodeWarrior change macro error" $errMsg $errCode
    }
    
    return $errMsg
}
      
