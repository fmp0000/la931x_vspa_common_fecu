# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025   NXP Semiconductors

# ==============================================================================
#! @file            test_run.tcl
#! @brief           TCL script for testing dot product implementation.
# ==============================================================================

# Change path to current script
cd [file dirname [info script]]

# Load TCL configuration (parameters)
source test_cfg.tcl

# Include common tcl scripts
source ../../../common/script/libsim.tcl
source ../../../common/script/passFail.tcl
source ../../../common/script/diffFiles.tcl
source ../../../common/script/cwUtils.tcl
source ../../../common/script/jenkins.tcl

# Initialize jenkins 
jenkinsInit

# Paths relative to this script
set ReportPath    "../../doc/cycShiftFD_Report.csv"
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
puts $Report_File  "Test Case,Test Status"

# Debug target
#debug CYCSHIFTFD_la9310_rdb
debug CYCSHIFTFD_la9310_cas

# Initialize debug
sim_init_config
    
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
    
	# Interpret sizes/addresses as decimal (for hex address use the prefix "0x") 
	radix d

    # ============================ Load input data =============================
    # Load input buffers
    restore -b "${tcDirPathIn}/inp.bin" m:[evaluate #x INP_BUFF] 16bit
	
	# Load control
	restore -b "${tcDirPathIn}/ctrl.bin" m:[evaluate #x &TEST_CTRL] 16bit
 
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
    # Output size (half-words)
	set out_size [evaluate #d  TEST_CTRL.out_len]
	set out_size [evaluate #d $out_size * 2]
	
	# Store output
    save -b m:[evaluate #x OUT_BUFF]#$out_size "${tcDirPathOut}/out.bin" -o 16bit
    
    # Set local error count
    set LocalErrorCount  0
    
    # Verify dot product
    set diffResult [diffFiles "${tcDirPathOut}/out.bin" "${tcDirPathRef}/out.bin"]
    if {$diffResult != $DIFF_FILE_MATCH} then {
        incr TotalErrorCount
        incr LocalErrorCount
        lappend Failures "Cyclic Shift error for TC ${TC_num} ..."
    }
    
    # Test status
    if {$LocalErrorCount == 0} then {
        set test_status "PASS"
    } else {
        set test_status "FAIL"
    }
    
    # Write number of cycles in file
    puts $Report_File  "$TC_num, $test_status"
    
    # Turn off breakpoints
    bp all off
	
	# Send message to Jenkins that the testing is still running to avoid timeout
    jenkinsSendMessage "running testcase $TC_num"
}

# Finish debug process
kill 

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

