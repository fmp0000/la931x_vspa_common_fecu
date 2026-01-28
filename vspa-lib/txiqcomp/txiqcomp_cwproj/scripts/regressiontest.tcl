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
set n_batches 2
set txiqcomp_target "test_txiqcomp_cas"
#set txiqcomp_target "test_txiqcomp_rdb"

# configure test case
set input_offset_word 512
set output_size_word 512
set output_offset_word 512
set test_name "generic"
set tempres [source "txiqcomp.tcl"]
set regressres [expr $regressres&$tempres]

# configure test case
set input_offset_word 512
set output_size_word 512
set output_offset_word 512
set test_name "txiqcomp2_512"
set tempres [source "txiqcomp.tcl"]
set regressres [expr $regressres&$tempres]

if {$regressres == 1} {
	puts "Regression Test PASS"
} else {
	puts "Regression Test FAIL"
}


# Send test report to Jenkins
set err_count [expr !$regressres]
jenkinsSendTestReport $err_count 
