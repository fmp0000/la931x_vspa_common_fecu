# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#source the library
source ../../common/script/jenkins.tcl
source ../../common/script/libsim.tcl
		
#debug la9310_fir_64_rdb
debug la9310_fir_64_cas

#initialize the setup
sim_init_config				
		
# load the test data
sim_dram_load "test_vectors/firFilter_input_h.hex" [evaluate #x taps_buffer]
sim_dram_load "test_vectors/firFilter_input_x.hex" [evaluate #x x_buffer]
sim_dram_load "test_vectors/firFilter_input_config.hex" [evaluate #x config_buffer]

# run the simulation
go
    
# save the output file
sim_dram_save "test_vectors/fir_output_y_cas.hex" [evaluate #x y_buffer] 2048*4

kill
		
# verify simulation output with reference
set testres [sim_file_match "test_vectors/fir_output_y_cas.hex" "test_vectors/firFilter_output_y_ref.hex" 2048]

return $testres
