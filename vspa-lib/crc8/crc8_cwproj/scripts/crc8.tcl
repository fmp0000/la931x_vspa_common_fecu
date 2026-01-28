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
debug "crc8_Debug_core00_LA9310_Download"

# Run testcase
sim_dram_load "../test_vectors/size.hex"  [evaluate #x &size]
sim_dram_load "../test_vectors/data1.hex" [evaluate #x &data1]
sim_dram_load "../test_vectors/data2.hex" [evaluate #x &data2]
go
wait 500
sim_dram_save "../test_vectors/crc_cw.hex" [evaluate #x &crc] 2
set status [sim_file_compare "../test_vectors/crc_cw.hex"  "../test_vectors/crc_matlab.hex"]
set err_count [expr !$status]

# Finish debug process
kill

# Send test report to Jenkins
jenkinsSendTestReport $err_count
