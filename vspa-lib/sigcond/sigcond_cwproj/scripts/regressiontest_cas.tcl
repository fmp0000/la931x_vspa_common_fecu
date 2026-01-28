# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#********************************************************************************

# Change path to current script
cd [file dirname [info script]]

# Add paths
source ../../../common/script/jenkins.tcl
source ../../../common/script/libsim.tcl

# Initialize jenkins 
jenkinsInit

set regressres 1
set n_batches 4
set opmode 0
set sigcond_target "test_sigcond_cas"

# test case 1: 2560
set input_offset_word 2560

# 160MHz
set output_size_word 2560
set output_offset_word 2560
set test_name "testN2560_BW160"
#set tempres [source "sigcond.tcl"]
#set regressres [expr $regressres&$tempres]

# 80MHz
set output_size_word 1280
set output_offset_word 1280
set test_name "testN2560_BW80"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

# test case 2: 1152
set input_offset_word 1152

# 160MHz
set output_size_word 1152
set output_offset_word 1152
set test_name "testN1152_BW160"
#set tempres [source "sigcond.tcl"]
#set regressres [expr $regressres&$tempres]

# test case 3: 640
set input_offset_word 640

# 80MHz
set output_size_word 320
set output_offset_word 320
set test_name "testN640_BW80"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

# 40MHz
set output_size_word 160
set output_offset_word 160
set test_name "testN640_BW40"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

# 20MHz
set output_size_word 80
set output_offset_word 96
set test_name "testN640_BW20"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

# test case 4: 256
set input_offset_word 256

# 80MHz
set output_size_word 128
set output_offset_word 128
set test_name "testN256_BW80"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

# 20MHz
set output_size_word 32
set output_offset_word 32
set test_name "testN256_BW20"
set tempres [source "sigcond.tcl"]
set regressres [expr $regressres&$tempres]

if {$regressres == 1} {
	puts "Regression Test PASS"
} else {
	puts "Regression Test FAIL"
}

# Send test report to Jenkins
set err_count [expr !$regressres]
jenkinsSendTestReport $err_count 

