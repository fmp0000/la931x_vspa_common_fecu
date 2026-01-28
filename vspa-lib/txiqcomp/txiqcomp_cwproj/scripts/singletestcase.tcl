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

# configure 1 test case
set n_batches 4
set input_offset_word 512
set output_size_word 512
set output_offset_word 512
#set test_name "txiqcomp2_512"
set test_name "generic"
set txiqcomp_target "test_txiqcomp_cas"
#set txiqcomp_target "test_txiqcomp_rdb"
set tempres [source "txiqcomp.tcl"]



