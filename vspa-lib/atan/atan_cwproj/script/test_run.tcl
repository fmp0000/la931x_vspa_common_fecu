# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025   NXP Semiconductors

# ==============================================================================
#! @file            test_run.tcl
#! @brief           TCL script for testing atan implementation.
# ==============================================================================

# Change path to current script
cd [file dirname [info script]]

# Load TCL configuration (parameters)
source test_cfg.tcl

# Get macro definitions
source test_macro.tcl

# Tester macros
set ATAN_PREC_HF16     0
set ATAN_PREC_HP16     1
set ATAN_PREC_SP32     2

# Include common tcl scripts
source ../../../common/script/libsim.tcl
source ../../../common/script/passFail.tcl
source ../../../common/script/diffFiles.tcl
source ../../../common/script/cwUtils.tcl
source ../../../common/script/jenkins.tcl

# Initialize jenkins 
jenkinsInit

# Paths relative to this script
set ReportPath    "../../doc/Atan_Report.csv"
set DirPathIn     "../vector/in"
set DirPathOut    "../vector/out"
set DirPathRef    "../vector/ref"
if { [file exists $DirPathOut] == 0 } {file mkdir $DirPathOut} 
 
# Set the total error count
set TotalErrorCount  0

# Interpret sizes/addresses as decimal (for hex address use the prefix "0x") 
radix D

# List of failed testcases and failures
set Failures {}

# Open report file
set Report_File [open "${ReportPath}" "w"]
puts $Report_File  "Test Case,Total cycles,Test Status"
jenkinsWriteReport "Atan_Report.csv" "Test Case,Total cycles,Test Status"
  
#=========================== START TESTCASE LOOP =================================
for {set TC_ind $TC_NUM_START} {$TC_ind <= $TC_NUM_END} {incr TC_ind} {

    #Set current testcase
    set TC_num [format "%03d" $TC_ind]
    
    puts "\n"
    puts "#########################################################################################"
    puts "####################################### TC$TC_num ###########################################"
    puts "#########################################################################################"

    # Input/Output/Reference directories
    set tcDirPathIn  "$DirPathIn/TC${TC_num}"
    set tcDirPathOut "$DirPathOut/TC${TC_num}" 
    set tcDirPathRef "$DirPathRef/TC${TC_num}" 
    if { [file exists $tcDirPathOut] == 0 } {file mkdir $tcDirPathOut}    
    
    # ============================ Change macros ===============================
    # Get testcase filter length
    set numCoeff [lindex $ATAN_NUM_COEFF $TC_ind]
    
    # Macro value
    set cwMacro [format "TEST_ATAN2_NUM_COEFF=%d" $numCoeff]
    puts "-> MACRO VALUE: ${cwMacro}"
    
    # Change macro
    puts "-> SETTING MACRO ..."
    cwChangeMacro $cwProjPath $cwProjConf $cwMacro set

    # ============================ Build project ===============================
    # Build project
    puts "-> BUILDING PROJECT ..."
    cwBuild $cwProjPath $cwProjConf
    
    # =========================== Enter debug mode =============================
    # Debug target
    puts "-> RUNNING PROJECT ..."
    debug $TARGET

    # Initialize debug
    sim_init_config
    
    # ============================ Load input data =============================
    # Load control structure
    restore -b "${tcDirPathIn}/ctrl.bin" m:[evaluate #x ATAN_TEST_CTRL] 16bit

    # Load input buffer
    restore -b "${tcDirPathIn}/input.bin" m:[evaluate #x ATAN_INP_BUFF] 16bit
 
    # ================================ RUN/DEBUG ===============================
    # Breakpoint at TCL_SYNC
    bp all off
    bp TCL_SYNC

    if {$DBG != 0} then {
        puts "###################################";
        puts "########## DEBUG MODE #############";
        puts "###################################";
        puts "Press any key to continue ..."
        gets stdin
    }
    
    # Run code
    go

    # ======================= Store output data & compare ======================    
    # Get output length (in half-words)
    set inputLen [evaluate #d ATAN_TEST_CTRL.inputLen]  
    set outPrec  [evaluate #d ATAN_TEST_CTRL.outPrec]  
    if {$outPrec == $ATAN_PREC_SP32} then {
        set outSize  [evaluate #d $inputLen * 2]
    } else {
        set outSize  [evaluate #d $inputLen]
    }   
    set outSizeh [format %#x $outSize]
    # Store atan output buffer
    
    save -b m:[evaluate #x ATAN_OUT_BUFF]#$outSizeh "${tcDirPathOut}/atan_out.bin" -o 16bit
    
    # Verify dot product
    set diffResult [diffFiles "${tcDirPathOut}/atan_out.bin" "${tcDirPathRef}/atan_ref.bin"]
    if {$diffResult != $DIFF_FILE_MATCH} then {
        incr TotalErrorCount
        set test_status "FAIL"
        lappend Failures "Atan error for TC ${TC_num} ..."
    } else {
        set test_status "PASS"
    }
    
    # Get number of cycles
    set numCycles  [evaluate #d clk_cycles]
    
    # Write number of cycles in file
    puts $Report_File  "$TC_num, $numCycles, $test_status"
    
    # Finish debug process
    kill 
    
    # Send message to Jenkins that the testing is still running to avoid timeout
    jenkinsSendMessage "running testcase $TC_num"

    # Write report for Jenkins
    jenkinsWriteReport "Atan_Report.csv" "$TC_num, $numCycles, $test_status"
}

# Print failures (if any)
for {set f_ind 0} {$f_ind < [llength $Failures]} {incr f_ind} {
    puts [lindex  $Failures  $f_ind]
}

# Print final error status
passFail $TotalErrorCount

# Close file
close $Report_File

# Send test report to Jenkins
jenkinsSendTestReport $TotalErrorCount

