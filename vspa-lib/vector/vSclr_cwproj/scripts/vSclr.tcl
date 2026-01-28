# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#* source "vSclr.tcl"
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

################################################################
## close all opened files (All those ids that start with "file")
################################################################ 
proc cfo {} {
    set fch_opened [file channels *]
    puts "File opened: $fch_opened"
    foreach fid $fch_opened {
        if ([string match "file*" $fid]) { 
            close $fid
            puts "One file closed." 
        }    
    }
}

# Close files
cfo
    
# Debug
debug vSclr_cas
#debug vSclr_rdb
    
# Initialize debug
sim_init_config
    
set TIME_start [clock clicks -milliseconds]
    
################### fixed parameters
# number of input DMEM lines for each test case
set nL 5
    
set nPass 0

################### inform main.c the number of input DMEM lines for each test case
sim_dram_write [evaluate #x &L] ${nL}
    
###################################### 
#    6 test cases in y = x + alpha   #
#    1 test case  in y = x * alpha   #
######################################
sim_dram_load "${tv_path}/L${nL}_rhf_x_in.hex" [evaluate #x x_rhf] "m"
sim_dram_load "${tv_path}/L${nL}_rhp_x_in.hex" [evaluate #x x_rhp] "m"
sim_dram_load "${tv_path}/L${nL}_rsp_x_in.hex" [evaluate #x x_rsp] "m"
sim_dram_load "${tv_path}/L${nL}_chf_x_in.hex" [evaluate #x x_chf] "m"
sim_dram_load "${tv_path}/L${nL}_chp_x_in.hex" [evaluate #x x_chp] "m"
sim_dram_load "${tv_path}/L${nL}_csp_x_in.hex" [evaluate #x x_csp] "m"
    
sim_dram_load "${tv_path}/L${nL}_rhf_alpha_in.hex" [evaluate #x alpha_rhf] "m"
sim_dram_load "${tv_path}/L${nL}_rhp_alpha_in.hex" [evaluate #x alpha_rhp] "m"
sim_dram_load "${tv_path}/L${nL}_rsp_alpha_in.hex" [evaluate #x alpha_rsp] "m"
sim_dram_load "${tv_path}/L${nL}_chf_alpha_in.hex" [evaluate #x alpha_chf] "m"
sim_dram_load "${tv_path}/L${nL}_chp_alpha_in.hex" [evaluate #x alpha_chp] "m"
sim_dram_load "${tv_path}/L${nL}_csp_alpha_in.hex" [evaluate #x alpha_csp] "m"
    
set n_word_y [expr (${nL}*32)]
set n_hword_y [expr (${L}*32*2)]
        
#return
go
#return

### size = number of words. 1 cSP = 2 words.    
sim_dram_save "${tv_path}/add_L${nL}_rhf_y_vspa.hex"      [evaluate #x add_y_rhf]         ${n_hword_y}
sim_dram_save "${tv_path}/add_L${nL}_rhp_y_vspa.hex"      [evaluate #x add_y_rhp]         ${n_hword_y}
sim_dram_save "${tv_path}/add_L${nL}_rsp_y_vspa.hex"      [evaluate #x add_y_rsp]         ${n_hword_y}
sim_dram_save "${tv_path}/add_L${nL}_chf_y_vspa.hex"      [evaluate #x add_y_chf]         ${n_hword_y}
sim_dram_save "${tv_path}/add_L${nL}_chp_y_vspa.hex"      [evaluate #x add_y_chp]         ${n_hword_y}
sim_dram_save "${tv_path}/add_L${nL}_csp_y_vspa.hex"      [evaluate #x add_y_csp]         ${n_hword_y}

sim_dram_save "${tv_path}/multi_L${nL}_rhf_rhf_rsp_y_vspa.hex"      [evaluate #x multi_y_rhf]         ${n_hword_y}
sim_dram_save "${tv_path}/multi_L${nL}_rhp_rhp_rsp_y_vspa.hex"      [evaluate #x multi_y_rhp]         ${n_hword_y}
sim_dram_save "${tv_path}/multi_L${nL}_rsp_rsp_rsp_y_vspa.hex"      [evaluate #x multi_y_rsp]         ${n_hword_y}

###
set k 0
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_rhf_y_vspa.hex"  "${tv_path}/add_L${nL}_rhf_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];    
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_rhp_y_vspa.hex"  "${tv_path}/add_L${nL}_rhp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_rsp_y_vspa.hex"  "${tv_path}/add_L${nL}_rsp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_chf_y_vspa.hex"  "${tv_path}/add_L${nL}_chf_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_chp_y_vspa.hex"  "${tv_path}/add_L${nL}_chp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/add_L${nL}_csp_y_vspa.hex"  "${tv_path}/add_L${nL}_csp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];

incr k; set isPass($k) [sim_file_match "${tv_path}/multi_L${nL}_rhf_rhf_rsp_y_vspa.hex"  "${tv_path}/multi_L${nL}_rhf_rhf_rsp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/multi_L${nL}_rhp_rhp_rsp_y_vspa.hex"  "${tv_path}/multi_L${nL}_rhp_rhp_rsp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];
incr k; set isPass($k) [sim_file_match "${tv_path}/multi_L${nL}_rsp_rsp_rsp_y_vspa.hex"  "${tv_path}/multi_L${nL}_rsp_rsp_rsp_y_BE.hex"    ${n_word_y} ];   set nPass [expr $nPass + $isPass($k)];

set nCase $k

for {set k 1} {$k <= $nCase} {incr k} {
    puts "case $k : $isPass($k)"
}    
    
puts "======= NUMBER OF Pass = $nPass (out of $nCase cases)"
    
puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr $nCase - $nPass]
jenkinsSendTestReport $err_count 
