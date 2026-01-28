# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

# Debug timeout
config DebugTimeout 1000

# Debug
debug "test_ditfft_cas"

# Initialize the setup
sim_init_config
		
# load the test data
sim_dram_load "../test_vectors/${test_name}_input_x.hex"      [evaluate #x input_buffer]
sim_dram_load "../test_vectors/${test_name}_input_config.hex" [evaluate #x config_buffer]

set output_size_hword [expr $output_size_word*2]

# Run the simulation
go
    
# Save the output file
sim_dram_save "../test_vectors/output_y_cas.hex" [evaluate #x output_buffer] $output_size_hword

# Finish debug process
kill

# Send message to Jenkins that the testing is still running to avoid timeout
jenkinsSendMessage "running testcase ${test_name}"
		
# verify simulation output with reference
puts "Verifying FFT output"
set testres [sim_file_match "../test_vectors/output_y_cas.hex" "../test_vectors/${test_name}_output_y_ref.hex" $output_size_word]
return $testres
