# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

# Change path to current script
cd [file dirname [info script]]

#source the library
source ../../../common/script/libsim.tcl

# configure 1 test case
#source "szconfig.tcl"
#set test_name "generic"

set regressres 1
set n_batches 4
set opmode 0

set input_offset_word 2560


set output_size_word 1280
set output_offset_word 1280
set test_name "testN2560_BW80"

set tempres [source "sigcond.tcl"]

