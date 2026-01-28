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

# Testvector path
set tv_path "../test_vectors"

# Debug
debug "qamMod_cas"

# Global test result
set res 1

# Run testcases
sim_dram_load "${tv_path}/input.hex" [evaluate #x bitIn]
go
sim_dram_save "${tv_path}/output_bpsk.hex" [evaluate #x qamOut] 2048
set res [expr $res && [sim_file_compare "${tv_path}/output_bpsk.hex" "${tv_path}/output_bpsk_expected.hex"]]

go
sim_dram_save  "${tv_path}/output_qpsk.hex" [evaluate #x qamOut] 1024
set res [expr $res && [sim_file_compare "${tv_path}/output_qpsk.hex" "${tv_path}/output_qpsk_expected.hex"]] 

go
sim_dram_save  "${tv_path}/output_16.hex" [evaluate #x qamOut] 512
set res [expr $res && [sim_file_compare "${tv_path}/output_16.hex" "${tv_path}/output_16_expected.hex"]] 

go
sim_dram_save  "${tv_path}/output_256.hex" [evaluate #x qamOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_256.hex" "${tv_path}/output_256_expected.hex"]] 


sim_dram_load "${tv_path}/input_64qam.hex" [evaluate #x bitIn]
go
sim_dram_save  "${tv_path}/output_64.hex" [evaluate #x qamOut] 2048
set res [expr $res && [sim_file_compare "${tv_path}/output_64.hex" "${tv_path}/output_64_expected.hex"]] 

sim_dram_load "${tv_path}/input_1024qam.hex" [evaluate #x bitIn]
go
sim_dram_save  "${tv_path}/output_1024.hex" [evaluate #x qamOut] 2048
set res [expr $res && [sim_file_compare "${tv_path}/output_1024.hex" "${tv_path}/output_1024_expected.hex"]] 

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr !$res]
jenkinsSendTestReport $err_count 
