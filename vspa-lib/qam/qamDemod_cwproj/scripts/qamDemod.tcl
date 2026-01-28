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
debug "qamDemod_CAS"

# Global test result
set res 1
sim_dram_load "${tv_path}/input_qpsk.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_Qpsk_V4.hex" [evaluate #x llrOutHF] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_Qpsk_V4.hex" "${tv_path}/output_Qpsk_V4_expected.hex"]]

sim_dram_load "${tv_path}/input_bpsk.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_Bpsk_V3.hex" [evaluate #x llrOut] 128
set res [expr $res && [sim_file_compare "${tv_path}/output_Bpsk_V3.hex" "${tv_path}/output_Bpsk_V3_expected.hex"]]


sim_dram_load "${tv_path}/input_qpsk.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_Qpsk_V3.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_Qpsk_V3.hex" "${tv_path}/output_Qpsk_V3_expected.hex"]]

sim_dram_load "${tv_path}/input_16.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_16_V3.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_16_V3.hex" "${tv_path}/output_16_V3_expected.hex"]]

sim_dram_load "${tv_path}/input_64.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_64_V3.hex" [evaluate #x llrOut] 384
set res [expr $res && [sim_file_compare "${tv_path}/output_64_V3.hex" "${tv_path}/output_64_V3_expected.hex"]]

sim_dram_load "${tv_path}/input_256V2.hex" [evaluate #x qamIn]
sim_dram_load "${tv_path}/snr.hex" [evaluate #x snr_vec]
go
sim_dram_save  "${tv_path}/output_256_V3.hex" [evaluate #x llrOut] 1024
set res [expr $res && [sim_file_compare "${tv_path}/output_256_V3.hex" "${tv_path}/output_256_V3_expected.hex"]] 

##### testing qamDemodNr
sim_dram_load "${tv_path}/input_qpsk.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_qpsk_Nr.hex" [evaluate #x llrOut] 128
set res [expr $res && [sim_file_compare "${tv_path}/output_qpsk_Nr.hex" "${tv_path}/output_qpsk_Nr_expected.hex"]] 

sim_dram_load "${tv_path}/input_256V2.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_256_Nr.hex" [evaluate #x llrOut] 1024
set res [expr $res && [sim_file_compare "${tv_path}/output_256_Nr.hex" "${tv_path}/output_256_Nr_expected.hex"]] 

##### testing qamDemodV2
sim_dram_load "${tv_path}/input_256V2.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_256V2.hex" [evaluate #x llrOut] 1024
set res [expr $res && [sim_file_compare "${tv_path}/output_256V2.hex" "${tv_path}/output_256_expectedV2.hex"]] 


#####single channel processing
sim_dram_load "${tv_path}/input_bpsk.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_bpsk.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_bpsk.hex" "${tv_path}/output_bpsk_expected.hex"]] 

sim_dram_load "${tv_path}/input_qpsk.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_qpsk.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_qpsk.hex" "${tv_path}/output_qpsk_expected.hex"]]  

sim_dram_load "${tv_path}/input_16.hex" [evaluate #x qamIn]
go 
sim_dram_save  "${tv_path}/output_16.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_16.hex" "${tv_path}/output_16_expected.hex"]]  

sim_dram_load "${tv_path}/input_64.hex" [evaluate #x qamIn]
go 
sim_dram_save  "${tv_path}/output_64.hex" [evaluate #x llrOut] 384
set res [expr $res && [sim_file_compare "${tv_path}/output_64.hex" "${tv_path}/output_64_expected.hex"]]  


sim_dram_load "${tv_path}/input_256.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_256.hex" [evaluate #x llrOut] 512
set res [expr $res && [sim_file_compare "${tv_path}/output_256.hex" "${tv_path}/output_256_expected.hex"]]  


sim_dram_load "${tv_path}/input_1024.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_1024.hex" [evaluate #x llrOut] 640
set res [expr $res && [sim_file_compare "${tv_path}/output_1024.hex" "${tv_path}/output_1024_expected.hex"]]  

#####dual channel processing
sim_dram_load "${tv_path}/input_bpsk.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_bpskch1.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_bpskch1.hex" "${tv_path}/output_bpsk_expected.hex"]] 
sim_dram_save  "${tv_path}/output_bpskch2.hex" [evaluate #x llrOut+512] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_bpskch2.hex" "${tv_path}/output_bpsk_expected.hex"]] 

sim_dram_load "${tv_path}/input_qpsk.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_qpskch1.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_qpskch1.hex" "${tv_path}/output_qpsk_expected.hex"]]  
sim_dram_save  "${tv_path}/output_qpskch2.hex" [evaluate #x llrOut+512] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_qpskch2.hex" "${tv_path}/output_qpsk_expected.hex"]]  

sim_dram_load "${tv_path}/input_16.hex" [evaluate #x qamIn]
go 
sim_dram_save  "${tv_path}/output_16ch1.hex" [evaluate #x llrOut] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_16ch1.hex" "${tv_path}/output_16_expected.hex"]]  
sim_dram_save  "${tv_path}/output_16ch2.hex" [evaluate #x llrOut+512] 256
set res [expr $res && [sim_file_compare "${tv_path}/output_16ch2.hex" "${tv_path}/output_16_expected.hex"]]  

sim_dram_load "${tv_path}/input_64.hex" [evaluate #x qamIn]
go 
sim_dram_save  "${tv_path}/output_64ch1.hex" [evaluate #x llrOut] 384
set res [expr $res && [sim_file_compare "${tv_path}/output_64ch1.hex" "${tv_path}/output_64_expected.hex"]]  
sim_dram_save  "${tv_path}/output_64ch2.hex" [evaluate #x llrOut+512] 384
set res [expr $res && [sim_file_compare "${tv_path}/output_64ch2.hex" "${tv_path}/output_64_expected.hex"]]  

sim_dram_load "${tv_path}/input_256.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_256ch1.hex" [evaluate #x llrOut] 512
set res [expr $res && [sim_file_compare "${tv_path}/output_256ch1.hex" "${tv_path}/output_256_expected.hex"]]  
sim_dram_save  "${tv_path}/output_256ch2.hex" [evaluate #x llrOut+512] 512
set res [expr $res && [sim_file_compare "${tv_path}/output_256ch2.hex" "${tv_path}/output_256_expected.hex"]]  

sim_dram_load "${tv_path}/input_1024.hex" [evaluate #x qamIn]
go
sim_dram_save  "${tv_path}/output_1024ch1.hex" [evaluate #x llrOut] 640
set res [expr $res && [sim_file_compare "${tv_path}/output_1024ch1.hex" "${tv_path}/output_1024_expected.hex"]]  
sim_dram_save  "${tv_path}/output_1024ch2.hex" [evaluate #x llrOut+512] 640
set res [expr $res && [sim_file_compare "${tv_path}/output_1024ch2.hex" "${tv_path}/output_1024_expected.hex"]]  

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr !$res]
jenkinsSendTestReport $err_count 
