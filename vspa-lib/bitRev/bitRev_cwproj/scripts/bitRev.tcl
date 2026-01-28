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

# Debug
debug "cas_bitRev"

# Initialize debug
sim_init_config
sim_ipreg_write CONTROL 1

# Run testcase
sim_dram_load "../test_vectors/input.hex"  [evaluate #x input]
go
#sim_dram_save "../test_vectors/bitRev_output.hex"  [evaluate #x [expr [evaluate #x out]-65536]] 512 im
sim_dram_save "../test_vectors/bitRev_output.hex"  [evaluate #x out] 512
set res [sim_file_compare "../test_vectors/bitRev_output.hex"  "../test_vectors/bitRev_output_be.hex"]

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr !$res]
jenkinsSendTestReport $err_count 

