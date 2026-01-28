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

set fftsz_set {64 128 256 512 1024 2048}

set regressres 1

# run FFT test cases
foreach fftsz $fftsz_set {
    puts "** Running test for $fftsz pt FFT with HFXIN SFLOUT"
    set output_size_word [expr $fftsz*2]
    set test_name "fft$fftsz\_type0"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
	
	puts "** Running test for $fftsz pt FFT with HFXIN HFXOUT"
    set output_size_word [expr $fftsz]
    set test_name "fft$fftsz\_type1"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
	
	puts "** Running test for $fftsz pt FFT with HFXIN HFLOUT"
    set output_size_word [expr $fftsz]
    set test_name "fft$fftsz\_type2"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
}

# run IFFT test cases
foreach fftsz $fftsz_set {
    puts "** Running test for $fftsz pt IFFT with HFXIN SFLOUT"
    set output_size_word [expr $fftsz*2]
    set test_name "ifft$fftsz\_type0"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
	
	puts "** Running test for $fftsz pt IFFT with HFXIN HFXOUT"
    set output_size_word [expr $fftsz]
    set test_name "ifft$fftsz\_type1"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
	
	puts "** Running test for $fftsz pt IFFT with HFXIN HFLOUT"
    set output_size_word [expr $fftsz]
    set test_name "ifft$fftsz\_type2"
	set tempres [source "fft.tcl"]
	set regressres [expr $regressres&$tempres]
}

if {$regressres == 1} {
	puts "DIF-FFT Regression Test PASS"
} else {
	puts "DIF-FFT Regression Test FAIL"
}

# Send test report to Jenkins
set err_count [expr !$regressres]
jenkinsSendTestReport $err_count 
