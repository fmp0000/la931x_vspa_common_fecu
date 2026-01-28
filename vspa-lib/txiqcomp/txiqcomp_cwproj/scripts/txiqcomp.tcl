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

# Debug config
config DebugTimeout 1000

# Testvector path
set tv_path "../test_vectors"

# Debug
debug $txiqcomp_target

#initialize the setup
sim_init_config

# load the configuration mode
sim_dram_load "${tv_path}/${test_name}_config.hex" [evaluate #x config_buffer]

# Get function type
set func_type [evaluate #d config_buffer\[2\]]
puts "Function type: ${func_type}"

# configure sig cond parameters
if {$func_type == 1} {
	sim_dram_load "${tv_path}/${test_name}_input_txiqcompstruct.hex" [evaluate #x txiqcompcfg_struct]
} else {
	sim_dram_load "${tv_path}/${test_name}_input_txiqcompstruct.hex" [evaluate #x txiqcompcfg2_struct]
}	

set output_size_hword [expr $output_size_word*2]
for {set i 0} {$i < $n_batches} {incr i} {
	set index [expr $i+1]
	set odd_flag [expr $i%2]

	if {$odd_flag == 0} {
		# load input data
		sim_dram_load "${tv_path}/${test_name}_input_x_batch$index.hex" [evaluate #x input_buffer]
	
		# run the simulation
		#anykey
		go
		
		# save the output file
		sim_dram_save "${tv_path}/output_y_batch$index\_cas.hex" [evaluate #x output_buffer] $output_size_hword
	} else {
		# load input data
		sim_dram_load "${tv_path}/${test_name}_input_x_batch$index.hex" [evaluate #x input_buffer+$input_offset_word]
	
		# run the simulation
		go
		
		# save the output file
		sim_dram_save "${tv_path}/output_y_batch$index\_cas.hex" [evaluate #x output_buffer+$output_offset_word] $output_size_hword
	}	
}

kill
		
# verify simulation output with reference
set finaltest_res 1
for {set i 1} {$i <= $n_batches} {incr i} {
	puts "Verifying output: batch $i"
	set testres [sim_file_match "${tv_path}/output_y_batch$i\_cas.hex" "${tv_path}/${test_name}_output_y_batch$i\_ref.hex" $output_size_word]
	set finaltest_res [expr $finaltest_res&$testres]
}		

if {$finaltest_res == 1} {
	puts "Test PASS"
} else {
	puts "Test FAIL"
}

return $testres
