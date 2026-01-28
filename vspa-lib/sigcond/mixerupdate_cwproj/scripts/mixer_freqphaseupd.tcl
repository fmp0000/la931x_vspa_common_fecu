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

# Debug config
config DebugTimeout 1000

# Testvector path
set tv_path "../test_vectors"

# Debug
#debug test_mixer_freqphaseupd_rdb
debug test_mixer_freqphaseupd_cas

#initialize the setup
sim_init_config
		
# load the test data
sim_dram_load "${tv_path}/input_config.hex" [evaluate #x config_buffer]
sim_dram_load "${tv_path}/input_mixerstruct.hex" [evaluate #x mixerParams]

# run the simulation
go
    
# save the output file
sim_dram_save "${tv_path}/output_x_cas.hex" [evaluate #x output_buffer] 2048
sim_dram_save "${tv_path}/output_mixerstruct_cas.hex" [evaluate #x mixerParams] 232
		
# verify simulation output with reference
puts "Verifying struct output"
set testres1 [sim_file_match "${tv_path}/output_mixerstruct_cas.hex" "${tv_path}/output_mixerstruct_ref.hex" 116]
puts "Verifying NCO output"
set testres2 [sim_file_match "${tv_path}/output_x_cas.hex" "${tv_path}/output_x_ref.hex" 1024]

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr !$testres1 + !$testres2]
jenkinsSendTestReport $err_count 
