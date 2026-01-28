# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#********************************************************************************
source ../../common/script/jenkins.tcl
source ../../common/script/libsim.tcl


set test_name "vectorXscalar_512"
set output_size_word 512

#set test_name "vectorXscalar_2048"
#set output_size_word 2048


# Debug config
config DebugTimeout 1000

# Testvector path
set tv_path "test_vectors"

# Debug
debug vsmult_cas
#debug vsmult_rdb

#initialize the setup
sim_init_config

# load the configuration mode
sim_dram_load "${tv_path}/${test_name}_config.hex" [evaluate #x config_buffer]
sim_dram_load "${tv_path}/${test_name}_input_x.hex" [evaluate #x x1]
sim_dram_load "${tv_path}/${test_name}_input_a.hex" [evaluate #x a]

set output_size_hword [expr $output_size_word*2]

# run the simulation
#anykey
go
		
# save the output file
sim_dram_save "${tv_path}/output_y_cas.hex" [evaluate #x y] $output_size_hword

kill

set finaltest_res 1
set testres [sim_file_match "${tv_path}/output_y_cas.hex" "${tv_path}/${test_name}_output_y_ref.hex" $output_size_word]
set finaltest_res [expr $finaltest_res&$testres]

if {$finaltest_res == 1} {
	puts "Test PASS"
} else {
	puts "Test FAIL"
}

return $testres
