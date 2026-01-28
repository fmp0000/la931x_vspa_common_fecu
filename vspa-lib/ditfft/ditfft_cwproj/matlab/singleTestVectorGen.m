% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% script singleTestVectorGen

addpath ../../matlab;
clear;

%% config
N = 512;
inv = 1;
input_offset = 31;

% 0=>HFL in, HFX out
% 1=>HFL in, SFL out (for FFT), HFL in, SFL intermediate, HFX out (for IFFT)
% 2=>SFL in, SFL out
prec_type = 2; 
test_name = 'generic';
%

ditfft_testbench(N, inv, prec_type, input_offset, test_name);

