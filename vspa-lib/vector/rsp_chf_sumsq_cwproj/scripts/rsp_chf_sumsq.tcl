# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#* source "rsp_chf_sumsq.tcl"
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
set n_test_cases 2

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
proc rsp_chf_sumsq_case {B n_word_y} {
    global tv_path
	set str_case "B${B}_"    
    puts " === testing... ${str_case}, n_word_y = ${n_word_y}."
    set n_hword_y [expr (${n_word_y}*2)]
    
    ##########################    
    sim_dram_write [evaluate #x &B] ${B}
    
    #return
    go
    #return
       
    set addr_y [evaluate #x y]
    puts "y addr: ${addr_y}"
    ########################## size = number of words. 1 cHP = 1 word.    
    puts "sim_dram_save ${tv_path}/${str_case}y_vspa.hex  ${addr_y}   ${n_hword_y}"
    sim_dram_save "${tv_path}/${str_case}y_vspa.hex"  ${addr_y}   ${n_hword_y}
    
    ##########################
    set isPass(1) [sim_file_match "${tv_path}/${str_case}y_vspa.hex"         "${tv_path}/${str_case}y_BE.hex"        ${n_word_y} ]    
    puts " === tested ${str_case}."
    
    ### Note: "array get" returns a list, not an array
    return [array get isPass]
}

# Close files
cfo        
    
# Debug
debug rsp_chf_sumsq_cas
#debug rsp_chf_sumsq_rdb
        
# Initialize debug
sim_init_config
    
################### fixed parameters        
set L 32

################### variable parameters
switch ${n_test_cases} {        
    2 {
        array set arr_B  { 1 {64} 2 {32} }
    }
            
    1 {
        array set arr_B  { 1 {32} }
    }
    
    default { error "invalid n_test_cases ${n_test_cases}" }
}
        
################### inform main.c the number of test cases
sim_dram_write [evaluate #x &nCase] ${n_test_cases}
sim_dram_write [evaluate #x &L] ${L}

## address in half-word
set addr_x [evaluate #x x]
puts "x addr: ${addr_x}"
    
sim_dram_load "${tv_path}/x_in.hex" ${addr_x} "m"

################### test results file
set logFileName "${tv_path}/testResults.txt"
set flog [open $logFileName "w"]

set TIME_start [clock clicks -milliseconds]
    
################### main loop for circular buffer test
set nPass(1) 0    
for {set iB 1}  {$iB  <= $n_test_cases}  {incr iB} {    
    
    set B $arr_B($iB)
    
    set listPass [ rsp_chf_sumsq_case $B [expr $L*32/$B] ]
    
    array set isPass $listPass
    
    ## record test results
    set nPass(1) [expr $nPass(1) + $isPass(1)]
            
    puts "--- case $iB : NUMBER OF Pass = $nPass(1) (out of $n_test_cases cases)"        
    puts "... wait for 1 second ..."
    wait 1000
    
    puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"
}

################################
# circular buffer test results #
################################
puts $flog "\n===\n Circular buffer: nPass/nCase: $nPass(1) / $n_test_cases."
    
#################### for linear buffer test
set listPass [ rsp_chf_sumsq_case 64 1 ]
array set isPass $listPass
    
################################
# linear buffer test results   #
################################
puts $flog "\n===\n Linear buffer: nPass/nCase: $isPass(1) / 1."    
close $flog
set flog [open $logFileName "r"]
puts "\n=========\n Results:"    
puts [read $flog]
close $flog
    
puts "TIME elpased: [expr [expr [clock clicks -milliseconds] - $TIME_start] / 1000] seconds"

# Finish debug process
kill

# Send test report to Jenkins
set err_count [expr $n_test_cases + 1 - $nPass(1) - $isPass(1)]
jenkinsSendTestReport $err_count 
