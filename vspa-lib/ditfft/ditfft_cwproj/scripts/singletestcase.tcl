# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

#********************************************************************************
#* Note: This script must be run from the script directory.
#********************************************************************************

# Change path to current script
cd [file dirname [info script]]

# Add paths
source libsim.tcl
source ../../../common/script/jenkins.tcl

# configure 1 test case
set output_size_word 1024
set test_name "generic"

set tempres [source "fft.tcl"]

