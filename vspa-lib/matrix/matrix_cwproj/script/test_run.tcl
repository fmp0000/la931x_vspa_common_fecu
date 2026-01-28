# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2016 - 2025   NXP Semiconductors

# ==============================================================================
#! @file            test_run.tcl
#! @brief           TCL script for testing MATRIX implementation.
# ==============================================================================

# Change path to current script
cd [file dirname [info script]]

# Load TCL configuration (parameters)
source test_cfg.tcl

# Include common tcl scripts
source ../../../common/script/libsim.tcl
source ../../../common/script/passFail.tcl
source ../../../common/script/diffFiles.tcl
source ../../../common/script/jenkins.tcl

# Initialize jenkins 
jenkinsInit

# Define types
set HALF_FIXED        0
set HALF_FLOAT        1
set SINGLE_PRECISION  2
set DOUBLE_PRECISION  3

# Paths relative to this script
set ReportPath    "../../doc/Matrix_Report.csv"
set DirPathIn     "../vector/in"
set DirPathOut    "../vector/out"
set DirPathRef    "../vector/ref"
if { [file exists $DirPathOut] == 0 } {file mkdir $DirPathOut} 
 
# Set the total error count
set TotalErrorCount  0

# List of failed testcases and failures
set Failures {}

# Open report file
set Report_File [open "${ReportPath}" "w"]
puts $Report_File  "Test Case,Total cycles,Test Status"
jenkinsWriteReport "Matrix_Report.csv" "Test Case,Total cycles,Test Status"

# Debug target
debug $TARGET

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
    # Load control structure
    restore -b "${tcDirPathIn}/ctrl.bin" m:[evaluate #x MATRIX_TEST_CTRL] 16bit

    # Load input vector
    restore -b "${tcDirPathIn}/vec.bin" m:[evaluate #x MATRIX_MULT_INP_VEC] 16bit
 
    # Load input matrix
    restore -b "${tcDirPathIn}/mat.bin" m:[evaluate #x MATRIX_MULT_INP_MAT] 16bit
    
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
    set dim1    [evaluate #d  MATRIX_TEST_CTRL.dim1]
    set dim2    [evaluate #d  MATRIX_TEST_CTRL.dim2]
    set dim3    [evaluate #d  MATRIX_TEST_CTRL.dim3]
    set outPrec [evaluate #d  MATRIX_TEST_CTRL.outPrec]

    # Get output size (half words)    
    if {$outPrec == $HALF_FIXED} then {
        set elem_size  1
    } elseif {$outPrec == $HALF_FLOAT} then {
        set elem_size  1
    } elseif {$outPrec == $SINGLE_PRECISION} then {
        set elem_size  2
    } elseif {$outPrec == $DOUBLE_PRECISION} then {
        set elem_size  4
    }        
    set outSize [evaluate #d $dim1 * $dim3 * $elem_size * 2]
    
    # Store output
    save -b m:[evaluate #x MATRIX_MULT_OUT_VEC]#$outSize "${tcDirPathOut}/out.bin" -o 16bit
    
    # Set local error count
    set LocalErrorCount  0
    
    # Verify output
    set diffResult [diffFiles "${tcDirPathOut}/out.bin" "${tcDirPathRef}/out.bin"]
    if {$diffResult != $DIFF_FILE_MATCH} then {
        incr TotalErrorCount
        incr LocalErrorCount
        lappend Failures "Matrix multiplication error for TC ${TC_num} ..."
    } 
    
    # Get number of cycles
    set numCycles  [evaluate #d clk_cycles]
    
    # Test status
    if {$LocalErrorCount == 0} then {
        set test_status "PASS"
    } else {
        set test_status "FAIL"
    }
    
    # Write number of cycles in file
    puts $Report_File  "$TC_num, $numCycles, $test_status"
    
    # Turn off breakpoints
    bp all off
    
    # Send message to Jenkins that the testing is still running to avoid timeout
    jenkinsSendMessage "running testcase $TC_num"

    # Write report for Jenkins
    jenkinsWriteReport "Matrix_Report.csv" "$TC_num, $numCycles, $test_status"
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

# Finish debug process
kill 
