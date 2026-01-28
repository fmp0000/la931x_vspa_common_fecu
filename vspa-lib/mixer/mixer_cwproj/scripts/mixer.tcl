# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
# source "mixer.tcl"
# run "mixer_test_main 28" to test 28 cases.
# run "mixer_test_main 7" to test 7 cases.
# run "mixer_test_main 1" to test 1 case.
#********************************************************************************

# Change path to current script
cd [file dirname [info script]]

# Add paths
source ../../../common/script/jenkins.tcl
source ../../../common/script/libsim.tcl

# Initialize jenkins 
jenkinsInit

# Number of testcases
set n_test_cases 28

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
## Test mixer case
################################################################ 
proc mixer_case {phaseidx freqidx L nCall} {
    set str_case "fIdx${freqidx}_pIdx${phaseidx}_"
    set n_word_y [expr (${L}*32)]
    set n_hword_y [expr (${L}*32*2)]
    set nhCall [expr (${nCall}*2)]

    puts " === testing... ${str_case}."
    
    ##########################
    sim_dram_load "../test_vectors/x_in.hex" [evaluate #x x] "m"
        
    #return
    go
    #return
    
    ########################## size = number of words. 1 cHP = 1 word.    
    sim_dram_save "../test_vectors/${str_case}y_vspa.hex"              [evaluate #x y]         ${n_hword_y}
    sim_dram_save "../test_vectors/${str_case}y_inplace_vspa.hex"      [evaluate #x x]         ${n_hword_y}
    sim_dram_save "../test_vectors/${str_case}phaseout_vspa.hex"           [evaluate #x PhaseOut1]   ${nhCall}
    sim_dram_save "../test_vectors/${str_case}phaseout_inplace_vspa.hex"   [evaluate #x PhaseOut2]   ${nhCall}



    ##########################
    set isPass(1) [sim_file_match  "../test_vectors/${str_case}y_vspa.hex"         "../test_vectors/${str_case}y_BE.hex"        ${n_word_y} ]    
    set isPass(2) [sim_file_match  "../test_vectors/${str_case}y_inplace_vspa.hex" "../test_vectors/${str_case}y_BE.hex"        ${n_word_y} ]
    set isPass(3) [sim_file_match  "../test_vectors/${str_case}phaseout_vspa.hex"          "../test_vectors/${str_case}phaseout_BE.hex"        ${nCall} ]    
    set isPass(4) [sim_file_match  "../test_vectors/${str_case}phaseout_inplace_vspa.hex"  "../test_vectors/${str_case}phaseout_BE.hex"        ${nCall} ]
        
    puts " === tested ${str_case}."
    
    ### Note: "array get" returns a list, not an array
    return [array get isPass]
}

# Close opened files
cfo
	
# Debug
debug mixer_cas
#debug mixer_rdb

# Initialize debug
sim_init_config

################### variable parameters
##### First call mixes 1 line, 2nd call mixes 2 lines, ..., 8th call mixes 8 lines. Total: L = 36 lines.
set L 36
set nCall 8

switch ${n_test_cases} {        
    28 {
        array set arr_freq   { 1 {1} 2 {2}  3 {3}  4 {4} }
        array set arr_phase  { 1 {1} 2 {2}  3 {3}  4 {4}   5 {5} 6 {6} 7 {7} }
    }
    
    7 {
        array set arr_freq   { 1 {1} }
        array set arr_phase  { 1 {1} 2 {2}  3 {3}  4 {4}   5 {5} 6 {6} 7 {7} }
    }
            
    1 {
        array set arr_freq   { 1 {1} }
        array set arr_phase  { 1 {1} }
    }
    
    default { error "invalid n_test_cases ${n_test_cases}" }
}

set nF [array size arr_freq]
set nP [array size arr_phase]

################### fixed parameters        
set nCase [expr $nF * $nP]
array set nPass { 1 {0} 2 {0} 3 {0} 4 {0} }

################### inform main.c the number of test cases
#memWrite32 [evaluate #x &nCase] ${nCase}

################### test results file
set logFileName ../test_vectors/testResults.txt
set flog [open $logFileName "w"]

set TIME_start [clock clicks -milliseconds]

################### main loop
sim_dram_load "../test_vectors/freq_in.hex" [evaluate #x FreqIn] "m"
sim_dram_load "../test_vectors/phas_in.hex" [evaluate #x PhaseIn] "m"

set iCase 0
for {set iF 1}  {$iF  <= $nF}  {incr iF} {
for {set iP 1}  {$iP  <= $nP}  {incr iP} {        
    incr iCase

    set listPass [mixer_case $iP $iF $L $nCall]
    array set isPass $listPass
    
    ## record test results
    set nPass(1) [expr $nPass(1) + $isPass(1)]
    set nPass(2) [expr $nPass(2) + $isPass(2)]
    set nPass(3) [expr $nPass(3) + $isPass(3)]
    set nPass(4) [expr $nPass(4) + $isPass(4)]
    
    puts -nonewline $flog "case $iCase : $isPass(1),$isPass(2),$isPass(3),$isPass(4)"
    puts "--- case $iCase : NUMBER OF Pass = $nPass(1),$nPass(2),$nPass(3),$nPass(4) (out of $nCase cases)"
    
    puts "... wait for 1 second ..."
    wait 1000
    
    puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"
}
}

################
# test results #
################
puts -nonewline $flog "\n===\n nPass/nCase: $nPass(1),$nPass(2),$nPass(3),$nPass(4) / $nCase."
close $flog
set flog [open $logFileName "r"]
puts [read $flog]
close $flog

puts "TIME elapsed: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"

# Finish debug process
kill

# Compute error count
set err_count [expr 4 * $nCase - ($nPass(1) + $nPass(2) + $nPass(3) + $nPass(4))]

# Send test report to Jenkins
jenkinsSendTestReport $err_count 
