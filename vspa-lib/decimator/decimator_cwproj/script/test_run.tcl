# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025   NXP Semiconductors

# ==============================================================================
#! @file            test_run.tcl
#! @brief           TCL script for testing Decimator implementation.
# ==============================================================================

# Change path to current script
cd [file dirname [info script]]

# Load TCL configuration (parameters)
source test_cfg.tcl

# Get macro definitions
source test_macro.tcl

# Include common tcl scripts
source ../../../common/script/libsim.tcl
source ../../../common/script/passFail.tcl
source ../../../common/script/diffFiles.tcl
source ../../../common/script/cwUtils.tcl
source ../../../common/script/jenkins.tcl

# Initialize jenkins 
jenkinsInit

# Paths relative to this script
set ReportPath    "../../doc/Decimator_Report.csv"
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
jenkinsWriteReport "Decimator_Report.csv" "Test Case,Total cycles,Test Status"

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
    set filterLen [lindex $DECIM_TEST_FLT_LEN  $TC_ind]
    
    # Macro value
    set cwMacro [format "TEST_DECIM_FLT_LEN=%d" $filterLen]
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
    restore -b "${tcDirPathIn}/ctrl.bin" m:[evaluate #x DECIM_TEST_CTRL] 16bit

    # Load input buffer
    restore -b "${tcDirPathIn}/input.bin" m:[evaluate #x DECIM_TEST_INP_BUFF] 16bit
 
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
    # Get params
    set decimFact [evaluate #d DECIM_TEST_CTRL.decimFact]
    set numBlocks [evaluate #d DECIM_TEST_CTRL.numBlocks]
    set outputLen [evaluate #d DECIM_TEST_CTRL.outputLen]
    
    # Get output size (half words)    
    set outSize [evaluate #d $numBlocks * $outputLen * 2]
    set outSizeh [format %#x $outSize]
    
    # Store output
    
    save -b m:[evaluate #x DECIM_TEST_OUT_BUFF]#$outSizeh "${tcDirPathOut}/output.bin" -o 16bit
   
    # Verify output data vs reference data
    set diffResult [diffFiles "${tcDirPathOut}/output.bin" "${tcDirPathRef}/output.bin"]
    if {$diffResult != $DIFF_FILE_MATCH} then {
        incr TotalErrorCount;
        lappend Failures "Decimator output error for TC ${TC_num} ..."
        set test_status "FAIL"
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
    jenkinsWriteReport "Decimator_Report.csv" "$TC_num, $numCycles, $test_status"
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
