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

config DebugTimeout 1000
debug "nco_phase_ramp_cas"
#debug "nco_phase_ramp_rdb"

#initialize the setup
sim_init_config
        
sim_dram_load "../test_vectors/nco_phase.hex"  [evaluate #x &phase_init]
sim_dram_load "../test_vectors/nco_freq.hex"   [evaluate #x &phase_ramp]
sim_dram_load "../test_vectors/g.hex"          [evaluate #x &gain_cpx]
        
# run the simulation
go
    
# save the output file
sim_dram_save "../test_vectors/output_vsp.hex" [evaluate #x PHASE_RAMP_OUT_BUFF] 512

# Finish debug process
kill

# verify simulation output with reference
set testres [sim_file_match "../test_vectors/output_vsp.hex" "../test_vectors/output_matlab.hex" 256]
set err_count [expr !$testres]

# Send test report to Jenkins
jenkinsSendTestReport $err_count 
