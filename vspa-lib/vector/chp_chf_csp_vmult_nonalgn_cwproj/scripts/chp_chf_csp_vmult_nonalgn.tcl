# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#* source "chp_chf_csp_vmult_nonalgn.tcl"
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

# Set number of testcases
set n_test_cases 7

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

################################################################
## Function to run a testcase
################################################################ 
proc chp_chf_csp_vmult_case {L} {
    global tv_path
	set str_case "L${L}_"
    set n_word_y [expr (${L}*32)] 
    set n_hword_y [expr (${L}*32*2)]
    puts " === testing... ${str_case}."
    
    ##########################    
    sim_dram_write [evaluate #x &L] ${L}
    sim_dram_load "${tv_path}/${str_case}x1_in.hex" [evaluate #x x1] "m"
    sim_dram_load "${tv_path}/${str_case}x2_in.hex" [evaluate #x x2] "m"
    
    #return
    go
    #return
    
    ########################## size = number of words. 1 cHP = 1 word.    
    sim_dram_save "${tv_path}/${str_case}y_vspa.hex"      [evaluate #x y]         ${n_hword_y}
    
    ##########################
    set isPass(1) [sim_file_match "${tv_path}/${str_case}y_vspa.hex"         "${tv_path}/${str_case}y_BE.hex"        ${n_word_y} ]    
    puts " === tested ${str_case}."
    
    ### Note: "array get" returns a list, not an array
    return [array get isPass]
}

# Close files
cfo

# Debug
debug chp_chf_csp_vmult_nonalgn_cas
#debug chp_chf_csp_vmult_nonalgn_rdb
	   
# Initialize debug	   
sim_init_config

################### variable parameters
switch ${n_test_cases} {        
    7 {
        array set arr_L  { 1 {1} 2 {2}  3 {3} 4 {4} 5 {8} 6 {15} 7 {31} }
    }
            
    1 {
        array set arr_L  { 1 {4} }
    }
    
    default { error "invalid n_test_cases ${n_test_cases}" }
}

set nL [array size arr_L]

################### fixed parameters        
set nCase [expr $nL]
array set nPass { 1 {0} }

################### inform main.c the number of test cases
sim_dram_write [evaluate #x &nCase] ${nCase}

################### test results file
set logFileName "${tv_path}/testResults.txt"
set flog [open $logFileName "w"]

set TIME_start [clock clicks -milliseconds]
   
################### main loop
set iCase 0
for {set iL 1}  {$iL  <= $nL}  {incr iL} {    
    
    set L $arr_L($iL)
    
    incr iCase

    set listPass [chp_chf_csp_vmult_case $L]
    array set isPass $listPass
    
    ## record test results
    set nPass(1) [expr $nPass(1) + $isPass(1)]
    
    puts -nonewline $flog "case $iCase : $isPass(1)"
    puts "--- case $iCase : NUMBER OF Pass = $nPass(1) (out of $nCase cases)"
    
    puts "... wait for 1 second ..."
    wait 1000
    
    puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"
}

################
# test results #
################
puts -nonewline $flog "\n===\n nPass/nCase: $nPass(1) / $nCase."
close $flog
set flog [open $logFileName "r"]
puts [read $flog]
close $flog

puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr $nCase - $nPass(1)]
jenkinsSendTestReport $err_count 
