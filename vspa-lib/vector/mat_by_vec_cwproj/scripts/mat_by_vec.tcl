# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#*
#* Note: This script must be run from the codewarrior project directory.
#*
#********************************************************************************




source ../../common/script/libsim.tcl

debug "mat_by_vec_cwproj_cas"

sim_dram_load test_vectors/x.hex [evaluate #x px]
sim_dram_load test_vectors/a_chfx.hex [evaluate #x pa_chfx]
sim_dram_load test_vectors/a_chfl.hex [evaluate #x pa_chfl]
sim_dram_load test_vectors/a_rhfx.hex [evaluate #x pa_rhfx]
sim_dram_load test_vectors/a_rhfl.hex [evaluate #x pa_rhfl]
sim_dram_load test_vectors/a_rfl.hex [evaluate #x pa_rfl]
sim_dram_load test_vectors/offset.hex [evaluate #x &offset]
sim_dram_load test_vectors/L.hex [evaluate #x &L]
sim_dram_load test_vectors/M.hex [evaluate #x &M]

go

sim_dram_save  "test_vectors/y1_CW.hex" [evaluate #x py1] 256
sim_dram_save  "test_vectors/y2_CW.hex" [evaluate #x py2] 256
sim_dram_save  "test_vectors/y3_CW.hex" [evaluate #x py3] 256
sim_dram_save  "test_vectors/y4_CW.hex" [evaluate #x py4] 256
sim_dram_save  "test_vectors/y5_CW.hex" [evaluate #x py5] 256
sim_dram_save  "test_vectors/y6_CW.hex" [evaluate #x py6] 256
sim_dram_save  "test_vectors/y7_CW.hex" [evaluate #x py7] 256
sim_dram_save  "test_vectors/y8_CW.hex" [evaluate #x py8] 256
sim_dram_save  "test_vectors/y9_CW.hex" [evaluate #x py9] 256
sim_dram_save  "test_vectors/y10_CW.hex" [evaluate #x py10] 256

sim_file_compare test_vectors/y1_CW.hex test_vectors/y1_matlab.hex
sim_file_compare test_vectors/y2_CW.hex test_vectors/y2_matlab.hex
sim_file_compare test_vectors/y3_CW.hex test_vectors/y3_matlab.hex
sim_file_compare test_vectors/y4_CW.hex test_vectors/y4_matlab.hex
sim_file_compare test_vectors/y5_CW.hex test_vectors/y5_matlab.hex
sim_file_compare test_vectors/y6_CW.hex test_vectors/y6_matlab.hex
sim_file_compare test_vectors/y7_CW.hex test_vectors/y7_matlab.hex
sim_file_compare test_vectors/y8_CW.hex test_vectors/y8_matlab.hex
sim_file_compare test_vectors/y9_CW.hex test_vectors/y9_matlab.hex
sim_file_compare test_vectors/y10_CW.hex test_vectors/y10_matlab.hex

# Finish debug process
kill
